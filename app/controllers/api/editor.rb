#!/bin/env ruby
# frozen_string_literal: true

PadrinoApp::App.controllers :editor, map: '/api/editor' do
  before do
    headers 'Content-Type' => 'application/json; charset=utf8'
  end

  post :install do
    data = JSON.parse request.body.read
    logger.info data

    ocmapp = OCMApp.first(app_install_id: data['app_install_id'])

    return 200, { success: true, info: 'App Already Installed.' }.to_json unless ocmapp.nil?

    data[:id] = SecureRandom.uuid
    data[:cpdm_user_id] = data['user_id'] if data.key? 'user_id'

    ocmapp = OCMApp.new(remove_elements(data, ['user_id']))

    return 200, { success: true, info: 'Install Successfull.', config: ocmapp }.to_json if ocmapp.save

    errors = []
    ocmapp.errors.each do |e|
      errors << e
      logger.error(e)
    end
    return 400, { success: false, info: errors }.to_json
  end
end
