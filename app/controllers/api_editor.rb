#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :editor, map: '/api/editor' do
  before do
    headers 'Content-Type' => 'application/json; charset=utf8'
  end

  post :install do
    logger.info params

    data = JSON.parse request.body.read
    logger.info data

    data[:id] = SecureRandom.uuid
    data[:cpdm_user_id] = data['user_id'] if data.key? 'user_id'

    return 200, { :success => true, :info => "Install Successful." }.to_json if OCMApp.first(params['app_install_id'])

    ocmapp = OCMApp.new(remove_elements(data, ['user_id']))

    # find out what to send back
    return 200, { :success => true, :info => "Install Successful.", :config => ocmapp }.to_json if ocmapp.save

    errors = []
    ocmapp.errors.each do |e|
      errors << e
      logger.error(e)
    end
    return 400, { :success => false, :info => errors }.to_json
  end
end
