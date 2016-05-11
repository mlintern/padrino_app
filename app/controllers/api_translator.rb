#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :api_translator, map: '/api/translator' do
  before do
    headers 'Content-Type' => 'application/json; charset=utf8'
  end

  ####
  # Endpoint: GET /api/translator
  # Description: Returns translator status
  # Authorization: translate
  # Arguments: None
  # Response: status as json object
  ####
  get :index do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    total = Project.all(user_id: auth_account.id).count
    active = Project.all(user_id: auth_account.id, status: 1).count
    canceled = Project.all(user_id: auth_account.id, status: 2).count
    completed = Project.all(user_id: auth_account.id, status: 3).count

    return 200, { :success => true, :info => "Up and Running with #{active} projects active out of #{total} total.", :data => { :total => total, :active => active, :canceled => canceled, :completed => completed }, :config => OCMApp.first({:user_id => auth_account.id}) || ['No App Configured'] }.to_json
  end

  ####
  # Endpoint: POST /api/translator/install
  # Description: Install application.  This will likely be used by Compendium to indicate that they are installing an app.
  # Authorization: translate
  # Arguments: None
  # Response: information as json object
  ####
  post :install do
    logger.info params

    data = JSON.parse request.body.read
    logger.info data

    data[:id] = SecureRandom.uuid
    data[:cpdm_user_id] = data['user_id'] if data.key? 'user_id'

    ocmapp = OCMApp.new(remove_elements(data, ['user_id']))

    if ocmapp.save
      # find out what to send back
      return 200, { :success => true, :info => "Install Successful.", :config => ocmapp }.to_json
    else
      errors = []
      ocmapp.errors.each do |e|
        errors << e
        logger.error(e)
      end
      return 400, { :success => false, :info => errors }.to_json
    end
  end

  ####
  # Endpoint: POST /api/translator/configure
  # Description: Install application.  This will allow you to update configuration settings from the app.
  # Authorization: translate
  # Arguments: Updates in JSON format
  # Response: information as json object
  ####
  post :configure do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    data = JSON.parse request.body.read
    logger.info data

    data[:cpdm_user_id] = data['user_id'] if data.key? 'user_id'

    ocmapp = OCMApp.first(app_install_id: data['app_install_id'])
    if ocmapp
      if ocmapp.user_id.nil?
        unless ocmapp.update(user_id: auth_account.id)
          errors = []
          ocmapp.errors.each do |e|
            errors << e
            logger.error(e)
          end
          return 400, { :success => false, :info => errors }.to_json
        end
      end
      if ocmapp.user_id == auth_account.id
        if ocmapp.update(remove_elements(data, %w(app_install_id user_id)))
          return 200, { :success => true, :info => "Update Successful.", :config => ocmapp }.to_json
        else
          errors = []
          ocmapp.errors.each do |e|
            errors << e
            logger.error(e)
          end
          return 400, { :success => false, :info => errors }.to_json
        end
      else
        return 403, { :success => false, :info => "You Do not have permissions to edit this Translator." }.to_json
      end
    else
      return 404, { :success => false, :info => "There were no apps matching this id." }.to_json
    end
  end

  ####
  # Endpoint: POST, PUT /api/translator/uninstall
  # Description: Uninstall application.  This will likely be used by Compendium to indicate that they are removing the app.
  # Authorization: none
  # Arguments: None
  # Response: information as json object
  ####
  [:post, :put].each do |method|
    send method, :uninstall do
      logger.info params

      data = JSON.parse request.body.read
      logger.info data # app_install_id, api_key

      ocmapp = OCMApp.first(app_install_id: data['app_install_id'])

      if ocmapp
        if ocmapp.destroy
          return 200, { :success => true, :info => "Uninstall Successful." }.to_json
        else
          errors = []
          ocmapp.errors.each do |e|
            errors << e
          end
          return 400, { :success => false, :info => errors }.to_json
        end
      else
        return 200, { :success => false, :info => "There were no Apps matching this id." }.to_json
      end
    end
  end

  ####
  # Endpoint: POST /api/translator/create_project
  # Description: endpoint to create project
  # Authorization: translate
  # Arguments: data from compendium
  # Response: information as json object
  ####
  post :create_project do
    data = JSON.parse request.body.read
    logger.info data

    ocmapp = OCMApp.first(app_install_id: data['app_install_id'])
    if ocmapp
      data[:id] = data['project_id']
      data[:user_id] = ocmapp.user_id
      destination_languages = data['target_languages']
      data[:language] = data['source_language']

      project = Project.new(remove_other_elements(data, [:id, :user_id, :name, :language, :description, :type]))
      if project.save
        if destination_languages && !destination_languages.empty?
          destination_languages.each do |lang|
            if ['pl', 'PL', 'pig latin', 'piglatin'].partial_include? lang
              language = Language.new(id: SecureRandom.uuid, project_id: project.id, name: lang, code: lang)
              if language.save
                language.inspect
              else
                language.errors.each do |e|
                  logger.error e
                end
              end
            else
              logger.debug project.destroy
              message = "#{lang} is not an accepted language. Accepted languages pl, PL"
              return 400, { :success => false, :info => message, :message => message, :error => message }.to_json
            end
          end
        end
        return 201, project.to_json
      else
        errors = []
        project.errors.each do |e|
          errors << e
        end
        return 400, { :success => false, :info => errors }.to_json
      end
    else
      return 400, { :success => false, :info => "There was no App with this ID" }.to_json
    end
  end

  ####
  # Endpoint: POST/PUT /api/translator/add_source
  # Description: endpoint to add source to project
  # Authorization: translate
  # Arguments: data from compendium
  # Response: information as json object
  ####
  [:post, :put].each do |method|
    send method, :add_source do
      data = JSON.parse request.body.read
      logger.info data

      ocmapp = OCMApp.first(app_install_id: data['app_install_id'])

      if ocmapp
        project = Project.get(data['project_id'])
        if project
          if project.status == 0
            begin
              project_assets = data['source_materials_add']
              project_assets.each do |pa|
                logger.info pa
                asset = Asset.first(external_id: pa['id'], project_id: project.id)
                if asset
                  logger.info 'Existing Asset'
                  unless asset.update(remove_elements(pa, [:id]))
                    errors = []
                    asset.errors.each do |e|
                      logger.error e
                      errors << e
                    end
                    return 400, { :success => false, :info => errors }.to_json
                  end
                else
                  logger.info 'New Asset'
                  new_asset = pa
                  new_asset[:language] = data['source_language']
                  new_asset[:project_id] = project.id
                  new_asset[:external_id] = pa['id']
                  new_asset[:id] = SecureRandom.uuid
                  new_asset[:source] = 1
                  asset = Asset.new(new_asset)
                  unless asset.save
                    errors = []
                    asset.errors.each do |e|
                      logger.error e
                      errors << e
                    end
                    return 400, { :success => false, :info => errors }.to_json
                  end
                end
              end
              return 200, { :success => true, :info => "Assets updated or added" }.to_json
            rescue Exception => e
              logger.error e
              return 500, { :success => false, :info => e }.to_json
            end
          else
            return 400, { :success => false, :info => "Project is not open" }.to_json
          end
        else
          return 404, { :success => false, :info => "Project does not exist." }.to_json
        end
      else
        return 400, { :success => false, :info => "There was no App with this ID" }.to_json
      end
    end
  end

  ####
  # Endpoint: POST /api/translator/project_canceled
  # Description: endpoint to cancel project
  # Authorization: none
  # Arguments: data from compendium
  # Response: information as json object
  ####
  post :project_canceled do
    data = JSON.parse request.body.read
    logger.info data

    ocmapp = OCMApp.first(app_install_id: params['app_install_id'])
    project = Project.get(params[:project_id])
    user = User.get(ocmapp.user_id)
    if project.update(status: 2)
      return 200, { :success => true, :info => "Project canceled." }.to_json
    else
      errors = []
      project.errors.each do |e|
        errors << e
      end
      return 400, { :success => false, :info => errors }.to_json
    end
  end

  ####
  # Endpoint: GET /api/translator/get_open_projects
  # Description: Returns open projects
  # Authorization: none
  # Arguments: optional - assets - boolean - true to include assets - default false
  # Response: list of open projects as json object
  ####
  get :get_open_projects do
    logger.info params
    data = []

    include_assets = params[:assets] || false
    include_asset_body = params[:asset_body] || false

    ocmapp = OCMApp.first(app_install_id: params['app_install_id'])
    status = %w(open in_progress canceled complete)
    if ocmapp
      if params[:project_ids]
        projects = Project.all(user_id: ocmapp.user_id, type: 0)
        projects.each do |p|
          if params[:project_ids].include? p.id.to_s
            data << { ocm_project_id: p.id, status: { ocm_code: status[p.status] } }
          end
        end
        data = data[0] if data.count == 1
      else
        projects = if params[:closed]
                     Project.all(user_id: ocmapp.user_id, status: [2, 3], type: 0)
                   else
                     Project.all(user_id: ocmapp.user_id, status: [0, 1], type: 0)
                   end
        projects.each do |p|
          data << { ocm_project_id: p.id, status: { ocm_code: status[p.status] } }
        end
      end
      logger.info data
      return 200, data.to_json
    else
      return 404, { :success => false, :info => "App Not Found" }.to_json
    end
  end

  ####
  # Endpoint: DELETE /api/translator/:id
  # Description: Delete a Tranlator App connection
  # Authorization: translate
  # Arguments: none
  # Response: information in json format
  ####
  delete :id, map: '/api/translator/:id' do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env['HTTP_AUTHORIZATION'], 'translate')

    app_install_id = params[:id]
    logger.info app_install_id
    ocmapp = OCMApp.first(app_install_id: app_install_id)
    if ocmapp && auth_account.id == ocmapp.user_id
      if ocmapp.destroy
        return 200, { :success => true, :info => "App Removed" }.to_json
      else
        errors = []
        ocmapp.errors.each do |e|
          errors << e
        end
        return 400, { :success => false, :info => errors }.to_json
      end
    else
      return 404, { :success => false, :info => "Could not Find App" }
    end
  end

  ####
  # Endpoint: POST/PUT /api/translator/add_source_auto_return
  # Description: endpoint to add source to project
  # Authorization: translate
  # Arguments: data from compendium
  # Response: information as json object
  ####
  [:post, :put].each do |method|
    send method, :add_source_auto_return do
      data = JSON.parse request.body.read
      logger.info data

      ocmapp = OCMApp.first(app_install_id: data['app_install_id'])

      if ocmapp
        project = Project.get(data['project_id'])
        if project
          if project.status == 0
            begin
              project_assets = data['source_materials_add']
              project_assets.each do |pa|
                logger.info pa
                asset = Asset.first(external_id: pa['id'], project_id: project.id)
                if asset
                  logger.info 'Existing Asset'
                  unless asset.update(remove_elements(pa, [:id]))
                    errors = []
                    asset.errors.each do |e|
                      logger.error e
                      errors << e
                    end
                    return 400, { :success => false, :info => errors }.to_json
                  end
                else
                  logger.info 'New Asset'
                  new_asset = pa
                  new_asset[:language] = data['source_language']
                  new_asset[:project_id] = project.id
                  new_asset[:external_id] = pa['id']
                  new_asset[:id] = SecureRandom.uuid
                  new_asset[:source] = 1
                  asset = Asset.new(new_asset)
                  if asset.save
                    user = Account.get(ocmapp.user_id)
                    logger.debug Background.perform_async(asset.id, user.auth_token)
                  else
                    errors = []
                    asset.errors.each do |e|
                      logger.error e
                      errors << e
                    end
                    return 400, { :success => false, :info => errors }.to_json
                  end
                end
              end
              puts project.update(status: 3)
              return 200, { :success => true, :info => "Assets added for auto translation" }.to_json
            rescue Exception => e
              logger.error e
              logger.error e.backtrace
              return 500, { :success => false, :info => e }.to_json
            end
          else
            return 400, { :success => false, :info => "Project is not open" }.to_json
          end
        else
          return 404, { :success => false, :info => "Project does not exist." }.to_json
        end
      else
        return 400, { :success => false, :info => "There was no App with this ID" }.to_json
      end
    end
  end
end
