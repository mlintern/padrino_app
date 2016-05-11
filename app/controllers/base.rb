#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

include FileUtils::Verbose

PadrinoApp::App.controllers :base, map: '/' do
  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => %w(OPTIONS GET POST)
  end

  get :index do
    if login(false)
      session[:redirect_to] = request.fullpath
      render 'base/api_info'
    else
      render 'base/index'
    end
  end

  options :upload do
    return 200
  end

  post :upload do
    logger.debug params.inspect

    response_hash = []
    if params['files'] && !params['files'].empty? && params['files'] != ['']
      files = params['files']
      files.each do |file|
        name = file[:filename]
        size = File.size(file[:tempfile])
        File.delete(file[:tempfile]) # Remove tmp file since we are not using it for anything
        response_hash << { name: name, size: size.to_human(1) }
      end
    end
    return 200, { :success => true, :files => response_hash }.to_json
  end
end
