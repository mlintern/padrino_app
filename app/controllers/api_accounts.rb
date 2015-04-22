PadrinoApp::App.controllers :accounts, :map => '/api/accounts' do

  before do
    headers "Content-Type" => "application/json; charset=utf8"
  end

  ####
  # Endpoint: GET /api/accounts
  # Description: Returns Accounts
  # Authorization: admin
  # Arguments: None
  # Response: json object of Accounts
  ####
  get :index do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin")

    accounts = Account.all

    @data = []
    accounts.each do |a|
      user_properties = AccountProperty.all(:id => a[:id])
      properties = {}
      user_properties.each do |up|
        properties[up.name.to_sym] = up.value
      end
      user = remove_elements(a.attributes)
      user[:properties] = properties
      @data << user
    end

    return 200, @data.to_json
  end

  ####
  # Endpoint: GET /api/accounts/me
  # Description: Returns information about authorized user
  # Authorization: login
  # Arguments: None
  # Response: json object of own Account
  ####
  get :me, :map => "/api/accounts/me" do
    account = api_auth(request.env["HTTP_AUTHORIZATION"], nil) # nil indicates any or no role is ok.  Only being logged in is neccessary.

    data = remove_elements(account.attributes)
    user_properties = AccountProperty.all(:id => account.id)
    properties = {}
    user_properties.each do |up|
      properties[up.name.to_sym] = up.value
    end
    data[:properties] = properties

    return 200, data.to_json
  end

  ####
  # Endpoint: GET /api/accounts/:id
  # Description: Returns information about user with :id
  # Authorization: owner of account or admin
  # Arguments: None
  # Response: json object of account with :id
  ####
  get :account, :map => "/api/accounts/:id" do
    api_owner?(request.env["HTTP_AUTHORIZATION"],params[:id]) || api_auth(request.env["HTTP_AUTHORIZATION"], "admin") # nil indicates any or no role is ok.  Only being logged in is neccessary.

    account = Account.all(:id => params[:id])[0]
    if account
      data = remove_elements(account.attributes)
      user_properties = AccountProperty.all(:id => params[:id])
      properties = {}
      user_properties.each do |up|
        properties[up.name.to_sym] = up.value
      end
      data[:properties] = properties
      return 200, data.to_json
    else
      headers "Content-Type" => "text/html; charset=utf8"
      return 404, { :success => false, :error => "User Not Found" }.to_json
    end
  end

  ####
  # Endpoint: POST /api/accounts
  # Description: Create new account
  # Authorization: owner of account or admin
  # Arguments: json object of data for new user
  #  optional: name, surname, role
  #  required: username, email, password, password_confirmation
  # Response: json object of account with :id
  ####
  post :index do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin")

    data = JSON.parse request.body.read

    data[:last_update] = DateTime.now
    data[:role] = data[:role] || ""
    data[:id] = SecureRandom.uuid

    add_update_properties(data)

    account = Account.new(data)
    if account.save
      return 200, account.to_json
    else
      errors = []
      account.errors.each do |e|
        errors << e
      end
      return 400, { :success => false, :errors => errors }.to_json
    end
  end

  ####
  # Endpoint: PUT /api/accounts/:id
  # Description: Updated account information
  # Authorization: owner of account or admin
  # Arguments: json object of data to update
  # Response: json object of account with :id
  ####
  put :account, :map => "/api/accounts/:id" do
    api_owner?(request.env["HTTP_AUTHORIZATION"],params[:id]) || api_auth(request.env["HTTP_AUTHORIZATION"], "admin") # nil indicates any or no role is ok.  Only being logged in is neccessary.

    data = JSON.parse request.body.read

    add_update_properties(data)

    account = Account.all(:id => params[:id])[0]
    remove_other_elements(data)
    if account
      data[:last_update] = DateTime.now
      if account.update(data)
        data = remove_elements(account.attributes)
        return 200, data.to_json
      else
        return 400, { :success => false, :error => "Bad Request" }.to_json
      end
    end

  end

  ####
  # Endpoint: DELETE /api/accounts/:id
  # Description: Delete an Account
  # Authorization: admin
  # Arguments: None
  # Response: json object with result
  ####
  delete :account, :map => "/api/accounts/:id" do
    auth_account = api_auth(request.env["HTTP_AUTHORIZATION"], "admin") # nil indicates any or no role is ok.  Only being logged in is neccessary.

    account = Account.get(params[:id])
    if account
      if ( account != auth_account ) && account.destroy
        return 200, { :success => true, :message => "Account #{params[:id]} was successfully deleted." }.to_json
      else
        return 400, { :success => false, :error => "You cannot delete yourself." }.to_json
      end
    else
      reutrn 404, { :success => false, :error => "Account does not exist." }.to_json
    end

  end

end
