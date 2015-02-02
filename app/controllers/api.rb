PadrinoApp::App.controllers :api do
  get :index do
    return 200, { :success => true, :content => "Hello World" }.to_json
  end

  get :accounts do
    admin

    options = {}
    if params[:direction] == "desc"
      if params[:order_by]
        options = { :order => [ params[:order_by].to_sym.desc ] }
      else
        options = { :order => [ :username.desc ] }
      end
    else
      if params[:order_by]
        options = { :order => [ params[:order_by].to_sym.asc ] }
      else
        options = { :order => [ :username.asc ] }
      end
    end

    accounts_list = Account.all(options)

    log("accounts_list",accounts_list.inspect)

    return accounts_list.to_json
  end

  get :info do
    return 200, { :success => true, :content => "Information about stuff." }.to_json
  end
end
