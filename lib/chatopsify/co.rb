# frozen_string_literal: true

require 'json'
require 'net/http'

module Chatopsify
  # ChatOps services
  class Co
    HTTP_OPEN_TIMEOUT = 5
    HTTP_READ_TIMEOUT = 30

    def initialize(api_key = nil)
      @api_key    = api_key || load_api_key
      @channel_id = load_channel_id
      @uri = load_uri
    end

    def self.call(*args, &block)
      new(*args, &block)
    end

    def process(body = nil, root_id = nil)
      body ||= Chatopsify::CoLib.msg_fmt

      send_request(body, root_id)
    rescue StandardError => e
      puts e.message
    end

    def call_delete(id = nil)
      send_delete_request(id)
    rescue StandardError => e
      puts e.message
    end

    private

    def load_uri
      ENV.fetch('CHATOPS_URI', nil) || # Load from env
        (fetch(:chatops_uri) if defined?(Capistrano)) # Load from Capistrano setting
    end

    def load_api_key
      ENV.fetch('CHATOPS_API_KEY', nil) || # Load from env
        (fetch(:chatops_api_key) if defined?(Capistrano)) # Load from Capistrano setting
    end

    def load_channel_id
      ENV.fetch('CHATOPS_CHANNEL_ID', nil) || # Load from env
        (fetch(:chatops_channel_id) if defined?(Capistrano)) # Load from Capistrano setting
    end

    def o_api_key
      Chatopsify::CoSecurity.call(@api_key).decrypt_string
    end

    def http_client(uri)
      if @http_client&.active? && @http_uri&.host == uri.host &&
         @http_uri&.port == uri.port && @http_uri&.scheme == uri.scheme
        return @http_client
      end

      reset_http_client

      client = Net::HTTP.new(uri.hostname, uri.port)
      client.use_ssl = uri.scheme == 'https'
      client.open_timeout = HTTP_OPEN_TIMEOUT
      client.read_timeout = HTTP_READ_TIMEOUT
      client.start

      @http_client = client
      @http_uri = uri
      client
    end

    def with_http_client(uri)
      client = http_client(uri)
      yield client
    rescue IOError, EOFError, Errno::ECONNRESET, Errno::EPIPE,
           Net::OpenTimeout, Net::ReadTimeout, Timeout::Error
      reset_http_client
      client = http_client(uri)
      yield client
    end

    def reset_http_client
      @http_client.finish if @http_client&.active?
    rescue IOError, EOFError
      nil
    ensure
      @http_client = nil
      @http_uri = nil
    end

    def send_request(msg, root_id)
      # puts "msg: #{msg}"
      uri = URI(@uri)

      req = Net::HTTP::Post.new(uri)
      req['authorization'] = "Bearer #{o_api_key}"
      req.content_type = 'application/json'
      req.body = { channel_id: @channel_id, message: msg, root_id: root_id }.to_json
      res = with_http_client(uri) { |http| http.request(req) }

      puts "Response: #{res.code} #{res.body}"
      JSON.parse(res.body)
    end

    def send_delete_request(id = nil)
      uri = URI(@uri)
      uri.path += "/#{id}" if id

      req = Net::HTTP::Delete.new(uri)
      req['authorization'] = "Bearer #{o_api_key}"
      res = with_http_client(uri) do |http|
        puts "req: #{req}"
        http.request(req)
      end

      puts "Response: #{res.code} #{res.body}"
    end
  end

  # ChatOps service libs
  class CoLib
    class << self
      def text(status)
        case status
        when :starting
          fetch(:chatops_deploy_starting_text)
        when :success
          fetch(:chatops_deploy_succeed_text)
        when :failed
          fetch(:chatops_deploy_failed_text)
        end
      end

      # rubocop:disable Lint/TripleQuotes, Style/StringLiterals, Layout/IndentationWidth
      def msg_fmt(status = nil)
"""#{text(status)}
| TITLE | CONTENTS |
|----------:|:-------------|
| Stage | #{fetch(:stage)&.upcase!} |
| Server | #{fetch(:ip_address)}|
| Branch | #{fetch(:branch)} |
| Revision | #{fetch(:current_revision) || '<empty>'} |
| Timestamp | #{Time.now.getlocal('+07:00') || Time.now} |
"""
      end
      # rubocop:enable Lint/TripleQuotes, Style/StringLiterals, Layout/IndentationWidth
    end
  end

  # CoSecurity service
  class CoSecurity
    require 'openssl'
    require 'securerandom'

    def self.call(*args, &block)
      new(*args, &block)
    end

    def initialize(str)
      @str = str
    end

    def encrypt_string
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.encrypt
      salt = SecureRandom.random_bytes(16)
      key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(generate_pwd, salt, 2000, cipher.key_len + cipher.iv_len)
      key = key_iv[0, cipher.key_len]
      iv = key_iv[cipher.key_len, cipher.iv_len]

      cipher.key = key
      cipher.iv = iv

      encrypted = cipher.update(@str) + cipher.final
      (salt + encrypted).unpack1('H*')
    rescue StandardError => e
      puts e.message
    end

    def decrypt_string
      encrypted = [@str].pack('H*')
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.decrypt

      salt = encrypted[0, 16]
      encrypted_data = encrypted[16..]

      key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(generate_pwd, salt, 2000, cipher.key_len + cipher.iv_len)
      key = key_iv[0, cipher.key_len]
      iv = key_iv[cipher.key_len, cipher.iv_len]

      cipher.key = key
      cipher.iv = iv

      cipher.update(encrypted_data) + cipher.final
    rescue StandardError => e
      puts e.message
    end

    private

    def generate_pwd
      self.class.to_s.split('::').last.upcase.reverse
    end
  end
end
