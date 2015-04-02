PadrinoApp::App.controllers :curl do
  get :index do
    permission_check('curl')

    render '/curl/index' 
  end

  post :index do
    permission_check('curl')

    if params[:session]['protocol'] == 'https://'
      curl_start = 'curl --insecure '
    else
      curl_start = 'curl '
    end

    if params[:session]['only_curl'] != 'on'
      @public = Nretnil::CompendiumAPI::CompendiumPublic.new(params[:session]['protocol']+params[:session]['server'])
      @compendium = Nretnil::CompendiumAPI::Compendium.new(params[:session]['username'], params[:session]['api_key'], params[:session]['protocol']+params[:session]['server'])
    end
    curl_auth = params[:session]['username']+':'+params[:session]['api_key']+'@'

    if params[:session]['body'].is_json?
      body = params[:session]['body'] || {}
    else
      body = eval(params[:session]['body']) || {}
    end

    query = eval(params[:session]['query']) || {}

    @result = { :results => 'Did not make request' }

    begin
      case params[:session]['call_type']
        when "get"
          curl_call = curl_start+'"'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+norm_data(query)+'"'
          if params[:session]['public'] == 'on'
            params[:session]['only_curl'] == 'on' ? true : @result = @public.get(params[:session]['api_uri'],query)
            curl_auth = ''
          else
            params[:session]['only_curl'] == 'on' ? true : @result = @compendium.get(params[:session]['api_uri'],query)
          end
        when "put"
          curl_call = curl_start+' --data \''+json_data(body)+'\' "'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XPUT'
          params[:session]['only_curl'] == 'on' ? true : @result = @compendium.put(params[:session]['api_uri'],body.to_s.is_json? ? body : body.to_json,query)
        when "post"
          curl_call = curl_start+' --data \''+json_data(body)+'\' "'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XPOST'
          params[:session]['only_curl'] == 'on' ? true : @result = @compendium.post(params[:session]['api_uri'],body.to_s.is_json? ? body : body.to_json,query)
        when "delete"
          curl_call = curl_start+' --data \''+json_data(body)+'\' "'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XDELETE'
          params[:session]['only_curl'] == 'on' ? true : @result = @compendium.delete(params[:session]['api_uri'],body.to_s.is_json? ? body : body.to_json,query)
        end
    rescue StandardError => e
      logger.error(e)
    end

    render 'curl/result', :locals => { :curl_call => curl_call, :result => @result }

  end

end
