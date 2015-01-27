PadrinoApp::App.controllers :api do
  get :index do
    return 200, { :success => true, :data => "Hello World" }.to_json
  end
end
