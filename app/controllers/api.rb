PadrinoApp::App.controllers :api do
  get :index do
    return 200, { :success => true, :content => "Hello World" }.to_json
  end

  get :accounts do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin")

    return 200, Account.all.to_json
  end

  get :info do
    return 200, { :success => true, :content => "Information about stuff." }.to_json
  end
end
