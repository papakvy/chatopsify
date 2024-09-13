module Chatopsify
  class CoService
    CO_URI = 'https://chat.runsystem.vn/api/v4/posts'.freeze

    def initialize(api_key, channel_id)
      @api_key = api_key
      @channel_id = channel_id
    end
  end
end
