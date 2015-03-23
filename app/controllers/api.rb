PadrinoApp::App.controllers :api do
  attributes_to_remove = [:token,:crypted_password,:last_update]
  allowed_attributes = [:username,:name,:surname,:email,:role,:password,:password_confirmation]

  before do
    headers "Content-Type" => "application/json; charset=utf8"
  end

  get :index do
    return 200, { :success => true, :content => "Hello World" }.to_json
  end

  get :accounts do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin")

    accounts = Account.all

    @data = []
    accounts.each do |a|
      user_properties = AccountProperty.all(:id => a[:id])
      properties = []
      user_properties.each do |up|
        properties << remove_elements(up.attributes,[:id])
      end
      user = remove_elements(a.attributes,attributes_to_remove)
      user[:properties] = properties
      @data << user
    end

    return 200, @data.to_json
  end

  get :me, :map => "/api/accounts/me" do
    account = api_auth(request.env["HTTP_AUTHORIZATION"], nil) # nil indicates any or no role is ok.  Only being logged is neccessary.

    data = remove_elements(account.attributes,attributes_to_remove)
    user_properties = AccountProperty.all(:id => params[:id])
    properties = []
    user_properties.each do |up|
      properties << remove_elements(up.attributes,[:id])
    end
    data[:properties] = properties

    return 200, data.to_json
  end

  get :account, :map => "/api/accounts/:id" do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin") # nil indicates any or no role is ok.  Only being logged is neccessary.

    account = Account.all(:id => params[:id])[0]
    if account
      data = remove_elements(account.attributes,attributes_to_remove)
      user_properties = AccountProperty.all(:id => params[:id])
      properties = []
      user_properties.each do |up|
        properties << remove_elements(up.attributes,[:id])
      end
      data[:properties] = properties
      return 200, data.to_json
    else
      return 404, { :success => false, :error => "User Not Found" }.to_json
    end

  end

  put :account, :map => "/api/accounts/:id" do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin") # nil indicates any or no role is ok.  Only being logged is neccessary.

    data = JSON.parse request.body.read

    add_update_properties(data)

    account = Account.all(:id => params[:id])[0]
    remove_other_elements(data,allowed_attributes)
    if account
      data[:last_update] = DateTime.now
      if account.update(data)
        data = remove_elements(account.attributes,attributes_to_remove)
        return 200, data.to_json
      else
        return 400, { :success => false, :error => "Bad Request" }.to_json
      end
    end

  end

  post :accounts do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin")

    data = JSON.parse request.body.read

    data[:last_update] = DateTime.now
    data[:role] = data[:role] || ""

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

  get :info do
    return 200, { :success => true, :info => [{ 1 =>"This endpoint provides information about the app.nretnil.com API." },{ 2 => "You are able to perform all Account management tasks via the API." }] }.to_json
  end

  post :external_pub do
    data = JSON.parse request.body.read
    log("Post Data: ", data)
    if data["content"]
      id = data['content'].try(:[],'remote_id') || rand(1000000)
      if data["content"]["title"]
        url = data['content'].try(:[],'remote_url') || 'http://www.hubot.com/' + data.try(:[],"content").try(:[],"title").downcase.gsub(' ','-')
        return 202, { :success => true, :id => id, :url => url }.to_json
      else
        return 400, { :success => false, :error => 'Missing Title' }.to_json
      end
    else
      return 400, { :success => false, :error => 'Bad Data' }.to_json
    end
  end

  post :debug, :map => "api/external_pub/debug" do
    data = JSON.parse request.body.read
    log("Post Data: ", data)
    if data["content"]
      id = data['content'].try(:[],'remote_id') || rand(1000000)
      if data["content"]["title"]
        url = data['content'].try(:[],'remote_url') || 'http://www.hubot.com/' + data.try(:[],"content").try(:[],"title").downcase.gsub(' ','-')
        return 202, { :success => true, :id => id, :url => url, :data_recieved => data }.to_json
      else
        return 400, { :success => false, :error => 'Missing Title', :data_recieved => data }.to_json
      end
    else
      return 400, { :success => false, :error => 'Bad Data', :data_recieved => data }.to_json
    end
  end

end