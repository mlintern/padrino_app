#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :api_projects, map: '/api/projects' do
  before do
    headers 'Content-Type' => 'application/json; charset=utf8'
  end

  ####
  # Endpoint: GET /api/projects
  # Description: Returns list of projects for authenticated user
  # Authorization: translate
  # Arguments: optional - assets - boolean - true to include assets - default false
  #            optional - asset_body - boolean - true to include asset_body - default false
  # Response: list of projects as json object
  ####
  get :index do
    account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')
    include_assets = params[:assets] || false
    include_asset_body = params[:asset_body] || false

    projects = Project.all(user_id: account.id)

    data = []
    projects.each do |p|
      project = p.attributes
      if include_assets
        project[:assets] = Asset.all(project_id: p.id) || []
        unless include_asset_body
          assets = project[:assets]
          data2 = []
          assets.each do |a|
            a.body = '<redacted>'
            data2 << a
          end
          project[:assets] = data2
        end
      end
      data << project
    end

    return 200, data.to_json
  end

  ####
  # Endpoint: POST /api/projects
  # Description: Create new Project as authenticated user
  # Authorization: translate
  # Arguments: destination_languages - optional - array of languaes with names and codes - [{ "name":"Spanish", "code":"ES" },{}]
  # Response: new project as json object
  ####
  post :index do
    account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    data = JSON.parse request.body.read

    data[:id] = SecureRandom.uuid
    data[:user_id] = account.id
    destination_languages = data['destination_languages']

    project = Project.new(remove_other_elements(data, [:id, :user_id, :name, :language, :description, :type]))
    if project.save
      if destination_languages && !destination_languages.empty?
        destination_languages.each do |lang|
          language = Language.new(id: SecureRandom.uuid, project_id: project.id, name: lang['name'], code: lang['code'])
          if language.save
            language.inspect
          else
            language.errors.each do |e|
              logger.error e
            end
          end
        end
      end
      return 200, project.to_json
    else
      errors = []
      project.errors.each do |e|
        errors << e
      end
      return 400, { :success => false, :info => errors }.to_json
    end
  end

  ####
  # Endpoint: PUT /api/projects/:id
  # Description: Update Project
  # Authorization: translate
  # Arguments: None
  # Response: updated project as json object
  ####
  put :index, with: :id do
    account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    data = JSON.parse request.body.read

    project = Project.get(params[:id])
    if project
      if project.update(remove_other_elements(data, [:name, :description, :language]))
        if project.type != 1
          ###
          # Send updated project to Compendium
          logger.info 'Update Project'
          signal_ocm(project)
          ###
        end
        return 200, project.to_json
      else
        errors = []
        project.errors.each do |e|
          errors << e
        end
        return 400, { :success => false, :info => errors }.to_json
      end
    else
      return 404, { :success => false, :info => "Project Not Found" }.to_json
    end
  end

  ####
  # Endpoint: GET /api/projects/:id
  # Description: Add Asset to Project
  # Authorization: translate
  # Arguments: None
  # Response: project as json object
  ####
  get :index, with: :id do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    project = Project.get(params[:id])
    if project
      return 200, project.to_json
    else
      return 404, { :success => false, :info => "Project Not Found" }.to_json
    end
  end

  ####
  # Endpoint: POST /api/projects/:id/start
  # Description: Create new Project
  # Authorization: translate
  # Arguments: None
  # Response: json object with result
  ####
  post :start, map: '/api/projects/:id/start' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    project = Project.get(params[:id])
    if project.user_id == auth_account.id
      if project.update(status: 1)
        ###
        # Send updated project to Compendium
        logger.info 'Start Project'
        signal_ocm(project)
        ###
        return 200, { :success => true, :info => "Project started." }.to_json
      else
        errors = []
        project.errors.each do |e|
          errors << e
        end
        return 400, { :success => false, :info => errors }.to_json
      end
    else
      return 403, { :success => false, :info => "You do not have permission to start project." }.to_json
    end
  end

  ####
  # Endpoint: POST /api/projects/:id/cancel
  # Description: Cancel Project
  # Authorization: translate
  # Arguments: None
  # Response: json object with result
  ####
  post :cancel, map: '/api/projects/:id/cancel' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    project = Project.get(params[:id])
    if project.user_id == auth_account.id
      if project.update(status: 2)
        ###
        # Send updated project to Compendium
        logger.info 'Canceled Project'
        signal_ocm(project)
        ###
        return 200, { :success => true, :info => "Project canceled." }.to_json
      else
        errors = []
        project.errors.each do |e|
          errors << e
        end
        return 400, { :success => false, :info => errors }.to_json
      end
    else
      return 403, { :success => false, :info => "You do not have permission to cancel project." }.to_json
    end

    return 200, @data.to_json
  end

  ####
  # Endpoint: POST /api/projects/:id/complete
  # Description: Cancel Project
  # Authorization: translate
  # Arguments: None
  # Response: json object with result
  ####
  post :cancel, map: '/api/projects/:id/complete' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    project = Project.get(params[:id])
    if project.user_id == auth_account.id
      if project.update(status: 3)
        ###
        # Send updated project to Compendium
        logger.info 'Complete Project'
        signal_ocm(project)
        ###
        return 200, { :success => true, :info => "Project completed." }.to_json
      else
        errors = []
        project.errors.each do |e|
          errors << e
        end
        return 400, { :success => false, :info => errors }.to_json
      end
    else
      return 403, { :success => false, :info => "You do not have permission to complete project." }.to_json
    end

    return 200, @data.to_json
  end

  ####
  # Endpoint: GET /api/projects/:id/assets
  # Description: Add Asset to Project
  # Authorization: translate
  # Arguments: None
  # Response: project's assets as json object
  ####
  get :add, map: '/api/projects/:id/assets' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    assets = Asset.all(project_id: params[:id])

    return 200, assets.to_json
  end

  ####
  # Endpoint: POST /api/projects/:id/assets
  # Description: Add Asset to Project
  # Authorization: translate
  # Arguments: None
  # Response: new asset as json object
  ####
  post :add, map: '/api/projects/:id/assets' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    data = JSON.parse request.body.read

    data[:project_id] = params[:id]
    data[:id] = SecureRandom.uuid
    data[:external_id] = SecureRandom.uuid
    data[:source] = true

    project = Project.get(params[:id])

    if project
      if project.language == data['language']
        if auth_account.id == project.user_id
          asset = Asset.new(remove_other_elements(data, [:id, :project_id, :title, :body, :source, :language, :external_id]))
          if asset.save
            return 200, asset.to_json
          else
            errors = []
            asset.errors.each do |e|
              errors << e
            end
            return 400, { :success => false, :info => errors }.to_json
          end
        else
          return 403, { :success => false, :info => "You do not have permissions to add to project." }.to_json
        end
      else
        return 400, { :success => false, :info => "Asset language must match project source language." }.to_json
      end
    else
      return 404, { :success => false, :info => "Project does not exist." }.to_json
    end
  end

  ####
  # Endpoint: DELETE /api/projects/:id
  # Description: delete project
  # Authorization: translate
  # Arguments: None
  # Response: json object with result
  ####
  delete :project, map: '/api/projects/:id' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    project = Project.get(params[:id])
    if project
      delete_project(project, auth_account)
    else
      return 404, { :success => false, :info => "Project does not exist." }.to_json
    end
  end
end
