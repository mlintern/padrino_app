#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :editor, map: '/editor' do
  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => %w(OPTIONS GET POST)
  end

  get :index do
    render 'editor/index', layout: 'minimal'
  end

  get :configure do
    logger.info params
    ocmapp = OCMApp.first(app_install_id: params['app_install_id'])
    message = if post_callback_auth(params['configuration_confirm_url'], { success: true, configured: true }, ocmapp.username, ocmapp.api_key)
                'Success'
              else
                'Danger'
              end
    logger.info params['configuration_confirm_url']
    render 'editor/info', layout: 'minimal', locals: { 'message' => message }
  end
end
