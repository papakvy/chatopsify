# frozen_string_literal: true

require 'json'
require 'net/http'
require 'tzinfo'

module Chatopsify
  # ChatOps service
  class Co
    def initialize(api_key = nil)
      @api_key    = api_key || load_api_key
      @channel_id = load_channel_id
      @uri = load_uri
    end

    def self.call(*args, &block)
      new(*args, &block)
    end

    def process(body = nil)
      body ||= Chatopsify::CoLib.msg_fmt

      send_request(body)
    rescue StandardError => e
      puts e.message
    end

    def call_get(id = nil)
      send_get_request(id)
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

    def send_request(msg)
      # puts "msg: #{msg}"
      uri = URI(@uri)

      req = Net::HTTP::Post.new(uri)
      req['authorization'] = "Bearer #{o_api_key}"
      req.content_type = 'application/json'
      req.body = { channel_id: @channel_id, message: msg }.to_json
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      puts "Response: #{res.code} #{res.body}"
    end

    def send_get_request(id = nil)
      uri = URI(@uri)
      uri.path += "/#{id}" if id

      # req = Net::HTTP::Get.new(co_uri)
      req = Net::HTTP::Delete.new(uri)
      req['authorization'] = "Bearer #{o_api_key}"
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
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

      def msg_fmt(status = nil)
"""#{text(status)}
| TITLE | CONTENTS |
|----------:|:-------------|
| Stage | #{fetch(:stage).upcase!} |
| Server | #{fetch(:ip_address) }|
| Branch | #{fetch(:branch)} |
| Revision | #{fetch(:current_revision) || '<empty>'} |
| Timestamp | #{TZInfo::Timezone.get('Asia/Ho_Chi_Minh')&.now || Time.now} |
"""
      end
    end
  end

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
      begin
        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.encrypt
        salt = SecureRandom.random_bytes(16)
        key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(generate_pwd, salt, 2000, cipher.key_len + cipher.iv_len)
        key = key_iv[0, cipher.key_len]
        iv = key_iv[cipher.key_len, cipher.iv_len]

        cipher.key = key
        cipher.iv = iv

        encrypted = cipher.update(@str) + cipher.final
        (salt + encrypted).unpack1('H*')
      rescue => e
        false
      end
    end

    def decrypt_string
      begin
        encrypted = [@str].pack('H*')
        cipher = OpenSSL::Cipher::AES256.new(:CBC)
        cipher.decrypt

        salt = encrypted[0, 16]
        encrypted_data = encrypted[16..-1]

        key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(generate_pwd, salt, 2000, cipher.key_len + cipher.iv_len)
        key = key_iv[0, cipher.key_len]
        iv = key_iv[cipher.key_len, cipher.iv_len]

        cipher.key = key
        cipher.iv = iv

        cipher.update(encrypted_data) + cipher.final
      rescue => e
        false
      end
    end

    private

    def generate_pwd
      self.class.to_s.split('::').last.upcase.reverse
    end
  end
end
