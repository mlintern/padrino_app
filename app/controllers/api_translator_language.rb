PadrinoApp::App.controllers :api_languages, :map => '/api/languages' do

  before do
    headers "Content-Type" => "application/json; charset=utf8"
  end

  ####
  # Endpoint: GET /api/languages/:id
  # Description: get asset data
  # Authorization: translate
  # Arguments: None
  # Response: language as json object
  ####
  get :index, :with => :id do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env["HTTP_AUTHORIZATION"], "translate")

    language = Language.get(params[:id])

    if language
      project = Project.get(language.project_id)
      if project.user_id = auth_account.id
        return 200, language.to_json
      else
        return 403, { :success => false, :info => "You do not have permission to perform this action." }.to_json
      end
    else
      return 404, { :success => false, :info => "Asset does not exist." }.to_json
    end
  end

  ####
  # Endpoint: POST /api/languages
  # Description: Add Language
  # Authorization: translate
  # Arguments: project_id - UUID -  id of project hte language will belong to.
  # Response: create language as json object
  ####
  post :index do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env["HTTP_AUTHORIZATION"], "translate")

    data = JSON.parse request.body.read

    data[:id] = SecureRandom.uuid

    project_id = data["project_id"] || nil

    if project_id
      project = Project.get(project_id)
      if project.user_id = auth_account.id
        language = Language.new(data)
        if language.save
          return 200, language.to_json
        else
          errors = []
          language.errors.each do |e|
            errors << e
          end
          return 400, { :success => false, :info => errors }.to_json
        end
      else
        return 403, { :success => false, :info => "You do not have permission to perform this action." }.to_json
      end
    else
      return 400, { :success => false, :info => "project_id is required." }.to_json
    end
  end

  ####
  # Endpoint: DELETE /api/languages/:id
  # Description: delete language from project
  # Authorization: translate
  # Arguments: None
  # Response: json object with result
  ####
  delete :index, :with => :id do
    auth_account = Account.auth_token_authenticate(params[:auth_token]) || api_auth(request.env["HTTP_AUTHORIZATION"], "translate")

    language = Language.get(params[:id])

    if language
      project = Project.get(language.project_id)
      if project.user_id = auth_account.id
        if language.destroy
          return 200, { :success => true, :info => "Langauge was successfully deleted." }.to_json
        else
          errors = []
          language.errors.each do |e|
            errors << e
          end
          return 400, { :success => false, :info => errors }.to_json
        end
      else
        return 403, { :success => false, :info => "You do not have permission to perform this action." }.to_json
      end
    else
      return 404, { :success => false, :info => "Language does not exist." }.to_json
    end
  end

end