PadrinoApp::App.controllers :base do
  get :index, :map => "/" do
    upr
    render "base/index"
  end
end
