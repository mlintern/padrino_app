PadrinoApp::App.controllers :api do
  get :index do
    return 200, { :success => true, :content => "Hello World" }.to_json
  end

  get :accounts do
    api_auth(request.env["HTTP_AUTHORIZATION"], "admin")

    return 200, Account.all.to_json
  end

  get :me, :map => "/api/accounts/me" do
    account = api_auth(request.env["HTTP_AUTHORIZATION"], nil) # nil indicates any or no role is ok.  Only being logged is neccessary.

    return 200, account.to_json
  end

  get :info do
    return 200, { :success => true, :content => "Information about stuff." }.to_json
  end

  post :external_pub do
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