PadrinoApp::App.controllers :base do
  get :index, :map => "/" do
    if login(false)
      session[:redirect_to] = request.fullpath
      render "base/api_info"
    else
      render "base/index"
    end
  end
end