#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

PadrinoApp::App.controllers :curl do
  get :index do
    logger.debug params
    permission_check('curl')

    uri = params['uri'] || '/api/password'
    query = params['query'] || '{ :symbols => false, :length => 25 }'
    host = params['host'] || 'app.nretnil.com'

    render '/curl/index', locals: { 'uri' => uri, 'query' => query, 'host' => host }
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
      headers = if params['headers'].is_json?
                  JSON.parse(params['headers']) || {}
                else
                  eval(params['headers']).map { |key, v| [key.to_s, v] }.to_h || {}
                end

      body = if params['body'].is_json?
               params['body'] || {}
             else
               eval(params['body']) || {}
             end

      query = if params['query'].is_json?
                JSON.parse(params['query']) || {}
              else
                eval(params['query']) || {}
              end
    rescue StandarError => e
      logger.error e.inspect
      logger.error(e.backtrace)
      headers = nil
      halt 400, '<div class="alert alert-danger">' + e.to_s + '</div>'
    end

    @result = { results: 'Did not make request' }

    @url = params['protocol'] + params['server'] + params['api_uri']

    begin
      case params['call_type']
      when 'get'
        curl_call = curl_start + '"' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + norm_data(query) + '"'
        if params['basic'] == 'on'
          params['only_curl'] == 'on' ? true : @result = HTTParty.get(@url, basic_auth: @auth, query: query, headers: headers, verify: secure)
        else
          params['only_curl'] == 'on' ? true : @result = HTTParty.get(@url, query: query, headers: headers, verify: secure)
        end
      when 'put'
        curl_call = curl_start + '--data \'' + json_data(body) + '\' "' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + '" -XPUT'
        params['only_curl'] == 'on' ? true : @result = HTTParty.put(@url, basic_auth: @auth, body: body.to_s.is_json? ? body : body.to_json, headers: headers, verify: secure)
      when 'post'
        curl_call = curl_start + '--data \'' + json_data(body) + '\' "' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + '" -XPOST'
        params['only_curl'] == 'on' ? true : @result = HTTParty.post(@url, basic_auth: @auth, body: body.to_s.is_json? ? body : body.to_json, headers: headers, verify: secure)
      when 'delete'
        curl_call = curl_start + '--data \'' + json_data(body) + '\' "' + params['protocol'] + curl_auth + params['server'] + params['api_uri'] + '" -XDELETE'
        params['only_curl'] == 'on' ? true : @result = HTTParty.delete(@url, basic_auth: @auth, query: query, headers: headers, verify: secure)
      end
    rescue StandardError => e
      logger.error(e)
      logger.error(e.backtrace)
      @result = { error: e }
    end

    logger.debug @result
    logger.debug @result.body.class
    render 'curl/result', locals: { curl_call: curl_call, result: @result, is_json: @result.body.valid_json? }
  end
end
