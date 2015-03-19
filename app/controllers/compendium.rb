PadrinoApp::App.controllers :compendium do

  get :index do
    compendium

    render '/compendium/index' 
  end

  post :index do
    compendium

    if params[:session]['only_curl'] != 'on'
      @public = Nretnil::CompendiumAPI::CompendiumPublic.new('https://'+params[:session]['server'])
      @compendium = Nretnil::CompendiumAPI::Compendium.new(params[:session]['username'], params[:session]['api_key'], 'https://'+params[:session]['server'])
    end
    curl_auth = params[:session]['username']+':'+params[:session]['api_key']+'@'

    if params[:session]['body'].is_json?
      body = params[:session]['body'] || {}
    else
      body = eval(params[:session]['body']) || {}
    end

    query = eval(params[:session]['query']) || {}

    @result = { :results => 'Did not make request' }

    case params[:session]['call_type']
      when "get"
        if params[:session]['public'] == 'on'
          params[:session]['only_curl'] == 'on' ? true : @result = @public.get(params[:session]['api_uri'],query)
          curl_auth = ''
        else
          params[:session]['only_curl'] == 'on' ? true : @result = @compendium.get(params[:session]['api_uri'],query)
        end
        curl_call = 'curl --insecure "https://'+curl_auth+params[:session]['server']+params[:session]['api_uri']+norm_data(query)+'"'
      when "put"
        params[:session]['only_curl'] == 'on' ? true : @result = @compendium.put(params[:session]['api_uri'],body.to_s.is_json? ? body : body.to_json,query)
        curl_call = 'curl --insecure --data \''+json_data(body)+'\' "https://'+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XPUT'
      when "post"
        params[:session]['only_curl'] == 'on' ? true : @result = @compendium.post(params[:session]['api_uri'],body.to_s.is_json? ? body : body.to_json,query)
        curl_call = 'curl --insecure --data \''+json_data(body)+'\' "https://'+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XPOST'
      when "delete"
        params[:session]['only_curl'] == 'on' ? true : @result = @compendium.delete(params[:session]['api_uri'],body.to_s.is_json? ? body : body.to_json,query)
        curl_call = 'curl --insecure --data \''+json_data(body)+'\' "https://'+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XDELETE'
      end

    render 'compendium/result', :locals => { :curl_call => curl_call, :result => @result }

  end

end
