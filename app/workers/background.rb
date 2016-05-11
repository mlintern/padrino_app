#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# Background Worker
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
  def perform(asset_id, auth_token)
    logger.info 'Performing Async Request'
    url = '/api/assets/' + asset_id + '/translate'
    response = HTTParty.post(ENV['SERVER_URL'] + url, body: { auth_token: auth_token })
    return true unless response.code != 200
    return response.parsed_response
  rescue StandardException => e
    logger.error e
    logger.error e.backtrace
    return false
  end
end
