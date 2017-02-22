#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :curl do
  get :index do
    logger.debug params
    session[:redirect_to] = url(:curl, :index) unless login(false)
    permission_check('curl')

    uri = params['api_uri'] || '/api/password'
    query = params['query'] || '{ :symbols => false, :length => 25 }'
    host = params['server'] || params['host'] || 'app.nretnil.com'
    protocol = params['protocol'] || 'https://'
    basic = params['basic'] || false
    secure = params['secure'] || false
    username = params['username'] || ''
    api_key = params['api_key'] || ''
    call_type = params['call_type'] || 'get'
    headers = params['headers'] || '{ "Accept" => "application/vnd.compendium.blog;version=2,application/json" }'
    body = params['body'] || '{ :post_title => "Content Title", :url_lookup_token => "content-title" }'

    render '/curl/index', locals: { 'uri' => uri, 'query' => query, 'host' => host, 'protocol' => protocol, 'basic' => basic, 'secure' => secure, 'username' => username, 'api_key' => api_key, 'call_type' => call_type, 'headers' => headers, 'body' => body }
  end

  post :index do
    logger.debug params
    permission_check('curl')

    curl_start = 'curl '

    if params['basic'] == 'on'
      curl_auth = params['username'] + ':' + params['api_key'] + '@'
      @auth = { username: params['username'], password: params['api_key'] }
    else
      curl_auth = ''
    end

    if params['secure'] == 'on'
      secure = true
    else
      curl_start += '--insecure '
      secure = false
    end

    begin
      headers = if params['headers'].valid_json?
                  JSON.parse(params['headers']) || {}
                elsif !params['headers'].empty?
                  string_to_hash(params['headers']).map { |key, v| [key.to_s, v] }.to_h || {}
                else
                  false
                end
      curl_headers = '-H\''
      if headers
        headers.each do |a, b|
          curl_headers += "#{a}: #{b}"
        end
        curl_headers += '\' '
      else
        curl_headers = ''
      end

      body = if params['body'].valid_json?
               params['body'] || {}
             else
               string_to_hash(params['body']) || {}
             end

      query = if params['query'].valid_json?
                JSON.parse(params['query']) || {}
              else
                string_to_hash(params['query']) || {}
              end

      @result = { results: 'Did not make request' }

      @url = params['protocol'] + params['server'] + params['api_uri']

      json_body = if body.to_s.valid_json?
                    body
                  else
                    body.to_json
                  end

      logger.debug json_body

      case params['call_type']
      when 'get'
        curl_call = curl_start + curl_headers + '"' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + norm_data(query) + '"'
        if params['basic'] == 'on'
          params['only_curl'] == 'on' ? true : @result = HTTParty.get(@url, basic_auth: @auth, query: query, headers: headers, verify: secure)
        else
          params['only_curl'] == 'on' ? true : @result = HTTParty.get(@url, query: query, headers: headers, verify: secure)
        end
      when 'put'
        curl_call = curl_start + curl_headers + '--data \'' + json_data(body) + '\' "' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + '" -XPUT'
        params['only_curl'] == 'on' ? true : @result = HTTParty.put(@url, basic_auth: @auth, body: json_body, headers: headers, verify: secure)
      when 'post'
        curl_call = curl_start + curl_headers + '--data \'' + json_data(body) + '\' "' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + '" -XPOST'
        params['only_curl'] == 'on' ? true : @result = HTTParty.post(@url, basic_auth: @auth, body: json_body, headers: headers, verify: secure)
      when 'delete'
        curl_call = curl_start + curl_headers + '--data \'' + json_data(body) + '\' "' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + '" -XDELETE'
        params['only_curl'] == 'on' ? true : @result = HTTParty.delete(@url, basic_auth: @auth, query: query, headers: headers, verify: secure)
      end

      logger.debug @result
      is_json = if params['only_curl'] == 'on'
                  true
                else
                  @result.body.valid_json?
                end
      render 'curl/result', locals: { curl_call: curl_call, result: @result, is_json: is_json }
    rescue JSON::ParserError => e
      logger.debug 'JSON SyntaxError'
      logger.error e.inspect
      logger.error e.backtrace
      flash[:error] = e.message
      query = params.map { |key, value| "#{key}=#{value}" }.join('&')
      redirect "/curl?#{query}"
    rescue SyntaxError => e
      logger.debug 'SyntaxError'
      logger.error e.inspect
      logger.error e.backtrace
      flash[:error] = e.message
      query = params.map { |key, value| "#{key}=#{value}" }.join('&')
      redirect "/curl?#{query}"
    rescue StandardError => e
      logger.error e
      logger.error e.backtrace
      @result = { error: e, body: { error: e }.to_json }
      render 'curl/result', locals: { curl_call: curl_call, result: @result, is_json: true }
    end
  end
end
