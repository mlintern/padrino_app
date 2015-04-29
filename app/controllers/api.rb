PadrinoApp::App.controllers :api do

  before do
    headers "Content-Type" => "application/json; charset=utf8",
            'Access-Control-Allow-Origin' => '*', 
            'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
  end

  ####
  # Endpoint: GET /api
  # Description: Hello World
  # Authorization: none
  # Arguments: None
  # Response: json object
  ####
  get :index do
    return 200, { :success => true, :content => "Hello World" }.to_json
  end

  ####
  # Endpoint: GET /api/info
  # Description: Returns information the api
  # Authorization: none
  # Arguments: none
  # Response: json object containing formation
  ####
  get :info do
    return 200, { :success => true, :info => [{ 1 =>"This endpoint provides information about the app.nretnil.com API." },{ 2 => "You are able to perform all Account management tasks via the API." }] }.to_json
  end

  ####
  # Endpoint: GET /api/password
  # Description: Returns information the api
  # Authorization: none
  # Arguments: 
  #   optional - length - number of characters in the password
  #   optional - symbols - boolean to determine if symbols will be included in password.
  # Response: json object containing formation
  ####
  get :password do
    symbols = params[:symbols] || true
    length = params[:length] || 15
    return 200, Nretnil::Password.generate(length.to_i,symbols.to_s.to_b).to_json
  end

  ####
  # Endpoint: POST /api/external_pub
  # Description: Endpoint for testing Compendiums External Publisher
  # Authorization: none
  # Arguments: json object of compendium data
  # Response: json object with success, id, and url
  ####
  post :external_pub do
    data = JSON.parse request.body.read
    logger.info("Post Data: "+data.inspect)
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

  ####
  # Endpoint: POST /api/external_pub/debug
  # Description: Endpoint for testing Compendiums External Publisher with extra returned information
  # Authorization: none
  # Arguments: json object of compendium data
  # Response: json object with success, id, url, and all data sent to endpoint
  ####
  post :debug, :map => "api/external_pub/debug" do
    data = JSON.parse request.body.read
    logger.info("Post Data: "+data.inspect)
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
