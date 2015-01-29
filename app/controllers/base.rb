PadrinoApp::App.controllers :base do
  get :index, :map => "/" do
    login

    session[:redirect_to] = request.fullpath
    render "base/index"
  end
end
