# frozen_string_literal: true

require 'json'
require 'net/http'
require 'tzinfo'

module Chatopsify
  # ChatOps service
  class Co
    CO_URI = ''
    CO_API_KEY = ''
    CO_CHANNEL_ID = ''

    def initialize(api_key = nil)
      @api_key    = api_key || load_api_key
      @channel_id = load_channel_id
    end

    def call(body = nil)
      body ||= CoLib.msg_fmt

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

    def load_api_key
      ENV.fetch('CHATOPS_CO_URI', nil) || # Load from env
        (fetch(:chatops_co_uri) if defined?(Capistrano)) || # Load from Capistrano setting
        CO_URI # Default
    end

    def load_co_uri
      ENV.fetch('CHATOPS_API_TOKEN', nil) || # Load from env
        (fetch(:chatops_api_key) if defined?(Capistrano)) || # Load from Capistrano setting
        CO_API_KEY # Default
    end

    def load_channel_id
      ENV.fetch('CHATOPS_CHANNEL_ID', nil) || # Load from env
        (fetch(:chatops_channel_id) if defined?(Capistrano)) || # Load from Capistrano setting
        CO_CHANNEL_ID # Default
    end

    def send_request(msg)
      puts "msg: #{msg}"
      # return
      co_uri = URI(CO_URI)

      req = Net::HTTP::Post.new(co_uri)
      req['authorization'] = "Bearer #{@api_key}"
      req.content_type = 'application/json'
      req.body = { channel_id: @channel_id, message: msg }.to_json
      res = Net::HTTP.start(co_uri.hostname, co_uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      puts "Response: #{res.code} #{res.body}"
    end

    def send_get_request(id = nil)
      # binding.pry
      co_uri = URI(CO_URI)
      co_uri.path += "/#{id}" if id

      puts "co_uri: #{co_uri}"

      # req = Net::HTTP::Get.new(co_uri)
      req = Net::HTTP::Delete.new(co_uri)
      req['authorization'] = "Bearer #{@api_key}"
      # req.content_type = 'application/json'
      # req.body = { channel_id: @channel_id, message: msg }.to_json
      res = Net::HTTP.start(co_uri.hostname, co_uri.port, use_ssl: true) do |http|
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

      def message_body(status = :starting)
        %(
[code]👻  #{text(status)}
● 𝕊𝕥𝕒𝕘𝕖  : #{fetch(:stage).upcase!}
● 𝕊𝕖𝕣𝕧𝕖𝕣  : #{fetch(:ip_address)}re
● 𝔹𝕣𝕒𝕟𝕔𝕙 : #{fetch(:branch)}
● ℝ𝕖𝕧𝕚𝕤𝕚𝕠𝕟: #{fetch(:current_revision) || '<empty>'}[/code]
        )
      end
    end
  end
end
