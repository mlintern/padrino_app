#!/bin/env ruby
# frozen_string_literal: true

PadrinoApp::App.controllers :editor, map: '/editor' do
  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => %w[OPTIONS GET POST]
  end

  get :index do
    logger.info params

    logger.info "content_id: #{params['content_id']}"
    logger.info "app_install_id: #{params['app_install_id']}"

    ocmapp = OCMApp.first(app_install_id: params['app_install_id'])
    post = nil
    unless params['content_id'].nil? || params['content_id'] == 'undefined' || ocmapp.nil?
      # session = Nretnil::CompendiumAPI::Compendium.new(ocmapp.username, ocmapp.api_key, 'https://dev.cpdm.oraclecorp.com')
      session = Nretnil::CompendiumAPI::Compendium.new('mlintern', '4mIV8kFBv788yOTv45rPNPMDRH7ra8s5JZzqjcP7', 'https://dev.cpdm.oraclecorp.com')
      logger.debug session.inspect
      post = session.content.get(params['content_id'])
      logger.debug(post)
    end

    @title = 'Editor'
    render 'editor/index', layout: 'editor', locals: { 'post' => post }
  end

  get :mce do
    logger.info params

    logger.info "content_id: #{params['content_id']}"
    logger.info "app_install_id: #{params['app_install_id']}"

    ocmapp = OCMApp.first(app_install_id: params['app_install_id'])
    post = nil
    unless params['content_id'].nil? || params['content_id'] == 'undefined' || ocmapp.nil?
      # session = Nretnil::CompendiumAPI::Compendium.new(ocmapp.username, ocmapp.api_key, 'https://dev.cpdm.oraclecorp.com') # app user does not have permission to get post content
      session = Nretnil::CompendiumAPI::Compendium.new('mlintern', '4mIV8kFBv788yOTv45rPNPMDRH7ra8s5JZzqjcP7', 'https://dev.cpdm.oraclecorp.com')
      logger.debug session.inspect
      post = session.content.get(params['content_id'])
      logger.debug(post)
    end

    @title = 'TinyMCE WYSIWYG'
    render 'editor/tinymce', layout: 'editor', locals: { 'post' => post }
  end

  get :iframe do
    logger.info params

    @title = 'TinyMCE WYSIWYG'
    render 'editor/iframe', layout: 'editor'
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
    @title = 'Configure Editor'
    render 'editor/info', layout: 'minimal', locals: { 'message' => message }
  end
end
