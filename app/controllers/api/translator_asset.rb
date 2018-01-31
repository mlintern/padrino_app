#!/bin/env ruby
# frozen_string_literal: true

PadrinoApp::App.controllers :api_assets, map: '/api/assets' do
  before do
    headers 'Content-Type' => 'application/json; charset=utf8'
  end

  ####
  # Endpoint: GET /api/assets/:id
  # Description: get asset data
  # Authorization: translate
  # Arguments: None
  # Response: asset as json object
  ####
  get :index, with: :id do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    asset = Asset.get(params[:id])

    return 404, { success: false, info: 'Asset does not exist.' }.to_json unless asset
    project = Project.get(asset.project_id)
    return 200, asset.to_json if project.user_id == auth_account.id
    return 403, { success: false, info: 'You do not have permission to perform this action.' }.to_json
  end

  ####
  # Endpoint: POST /api/assets/:id/translate
  # Description: translate asset
  # Authorization: translate
  # Arguments: None
  # Response: translated asset(s) in json object
  ####
  post :translate, map: '/api/assets/:id/translate' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    asset = Asset.get(params[:id])

    already_translated = Asset.all(source_id: asset.external_id, project_id: asset.project_id)
    finished_langs = already_translated.map { |at| at.language.downcase }

    return 404, { success: false, info: 'Asset does not exist.' }.to_json unless asset

    return 400, { success: false, info: 'Asset is not in a Ready State.' }.to_json unless asset.status.zero? || asset.status == 3

    project = Project.get(asset.project_id)
    return 403, { success: false, info: 'You do not have permission to perform this action.' }.to_json unless project.user_id == auth_account.id

    languages = Language.all(project_id: project.id)
    new_assets = []
    errors = []
    languages.each do |lang|
      next if finished_langs.include? lang.name.downcase
      data = {}
      data[:source_id] = asset.external_id
      data[:project_id] = project.id
      data[:id] = SecureRandom.uuid
      data[:language] = lang.name
      data[:status] = 2
      data[:title] = translate_piglatin_title(asset.title, lang.name)
      data[:body] = translate_piglatin(asset.body)
      new_asset = Asset.new(data)
      if new_asset.save
        ### Send new asset to OCM
        ocmapp = OCMApp.first(user_id: auth_account.id)
        if ocmapp && project.type.to_i.zero?
          logger.info 'Sending Post to Compendium'
          logger.info data
          logger.debug result = ocm_create_post(data, ocmapp)
        else
          result = true
        end
        if result == true
          new_assets << new_asset
        else
          new_asset.destroy
          errors << (result.is_a?(Hash) ? result['error'] : JSON.parse(result)['error'])
        end
      else
        new_asset.errors.each do |e|
          errors << e
        end
      end
    end
    if !errors.empty?
      asset.update(status: 3)
      logger.error errors.inspect
      return 400, { success: false, info: errors }.to_json
    else
      asset.update(status: 1) if languages.count > 0
      return 200, new_assets.to_json
    end
  end

  ####
  # Endpoint: DELETE /api/assets/:id
  # Description: delete asset from project
  # Authorization: translate
  # Arguments: None
  # Response: json object with result
  ####
  delete :index, with: :id do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    asset = Asset.get(params[:id])

    return 404, { success: false, info: 'Asset does not exist.' }.to_json unless asset

    project = Project.get(asset.project_id)
    return 403, { success: false, info: 'You do not have permission to perform this action.' }.to_json unless project.user_id == auth_account.id
    return 200, { success: true, info: 'Asset was successfully deleted.' }.to_json if asset.destroy

    errors = []
    asset.errors.each do |e|
      errors << e
    end
    return 400, { success: false, info: errors }.to_json
  end
end
