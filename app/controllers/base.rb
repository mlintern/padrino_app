PadrinoApp::App.controllers :base do
  get :index, :map => "/" do
    user
    session[:redirect_to] = request.fullpath
    
    render "base/index"
  end
end
