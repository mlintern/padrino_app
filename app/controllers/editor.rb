#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :editor, map: '/editor' do
  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => %w(OPTIONS GET POST)
  end

  get :index do
    logger.info params

    @title = 'Editor'
    render 'editor/index', layout: 'editor'
  end

  get :mce do
    logger.info params

    @title = 'TinyMCE Editor'
    render 'editor/tinymce', layout: 'editor'
  end

  get :configure do
    logger.info params
    logger.debug ocmapp = OCMApp.first(app_install_id: params['app_install_id'])
    message = 'App Id Not Found'
    unless ocmapp.nil?
      message = if post_callback_auth(params['configuration_confirm_url'], { success: true, configured: true }, ocmapp.username, ocmapp.api_key)
                  'Success'
                else
                  'Danger'
                end
      logger.info params['configuration_confirm_url']
    end
    render 'editor/info', layout: 'minimal', locals: { 'message' => message }
  end
end
