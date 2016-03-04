PadrinoApp::App.controllers :curl do
  get :index do
    permission_check('curl')

    render '/curl/index' 
  end

  post :index do
    logger.debug params[:session]
    permission_check('curl')

    curl_start = 'curl '

    unless params[:session]['public'] == 'on'
      curl_auth = params[:session]['username']+':'+params[:session]['api_key']+'@'
      @auth = { :username => params[:session]['username'], :password => params[:session]['api_key'] }
    else
      curl_auth = ''
    end

    if params[:session]['secure'] == 'on'
      secure = true
    else
      curl_start += "--insecure "
      secure = false
    end

    begin
      if params[:session]['headers'].is_json?
        headers = JSON.parse(params[:session]['headers']) || {}
      else
        headers = eval(params[:session]['headers']).map{|key, v| [key.to_s, v] }.to_h || {}
      end
    rescue Exception => e
      logger.error e.inspect
      logger.error(e.backtrace)
      headers = nil
      halt 400, '<div class="alert alert-danger">' + e.to_s + '</div>'
    end

    begin
      if params[:session]['body'].is_json?
        body = params[:session]['body'] || {}
      else
        body = eval(params[:session]['body']) || {}
      end
    rescue Exception => e
      logger.error e.inspect
      logger.error(e.backtrace)
      headers = nil
      halt 400, '<div class="alert alert-danger">' + e.to_s + '</div>'
    end

    begin
      if params[:session]['query'].is_json?
        query = JSON.parse(params[:session]['query']) || {}
      else
        query = eval(params[:session]['query']) || {}
      end
    rescue Exception => e
      logger.error e.inspect
      logger.error(e.backtrace)
      headers = nil
      halt 400, '<div class="alert alert-danger">' + e.to_s + '</div>'
    end

    @result = { :results => 'Did not make request' }

    @url = params[:session]['protocol']+params[:session]['server']+params[:session]['api_uri']

    begin
      case params[:session]['call_type']
        when "get"
          curl_call = curl_start+'"'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+norm_data(query)+'"'
          if params[:session]['public'] == 'on'
            params[:session]['only_curl'] == 'on' ? true : @result = HTTParty.get(@url, :query => query, :headers => headers, :verify => secure)
          else
            params[:session]['only_curl'] == 'on' ? true : @result = HTTParty.get(@url, :basic_auth => @auth, :query => query, :headers => headers, :verify => secure)
          end
        when "put"
          curl_call = curl_start+'--data \''+json_data(body)+'\' "'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XPUT'
          params[:session]['only_curl'] == 'on' ? true : @result = HTTParty.put(@url, :basic_auth => @auth, :body => body.to_s.is_json? ? body : body.to_json, :headers => headers, :verify => secure)
        when "post"
          curl_call = curl_start+'--data \''+json_data(body)+'\' "'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XPOST'
          params[:session]['only_curl'] == 'on' ? true : @result = HTTParty.post(@url, :basic_auth => @auth, :body => body.to_s.is_json? ? body : body.to_json, :headers => headers, :verify => secure)
        when "delete"
          curl_call = curl_start+'--data \''+json_data(body)+'\' "'+params[:session]['protocol']+curl_auth+params[:session]['server']+params[:session]['api_uri']+'" -XDELETE'
          params[:session]['only_curl'] == 'on' ? true : @result = HTTParty.delete(@url, :basic_auth => @auth, :query => query, :headers => headers, :verify => secure)
        end
    rescue StandardError => e
      logger.error(e)
      logger.error(e.backtrace)
      @result = { :error => e }
    end

    logger.info @result
    render 'curl/result', :locals => { :curl_call => curl_call, :result => @result }

  end

end
