module Sidekiq
  class CLI
    private

    def print_banner
      # banner taking up all my screen :)
    end
  end
end

class Background
  include Sidekiq::Worker
  sidekiq_options queue: 'translate'

  ####
  # Name: perform(asset_id,auth_token)
  # Description: take asset id and auth_token to request translation of asset
  # Arguments: asset_id - id of asset to translate
  #            auth_token - user who owns project's auth token
  # Response: boolean
  ####
  def perform(asset_id,auth_token)
    logger.info "Performing Async Request"
    begin
      url = "/api/assets/"+asset_id+"/translate"
      response = HTTParty.post(ENV['SERVER_URL']+url, :body => { :auth_token => auth_token })
      if response.code == 200
        return true
      else
        return response.parsed_response
      end
    rescue Exception => e
      logger.error e
      logger.error e.backtrace
      return false
    end
  end
end