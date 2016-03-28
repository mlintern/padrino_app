#!/bin/env ruby
# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + './../watir-selenium')

class SignInOut < SeleniumTests

  def test_sign_in_as_admin
    begin
      sign_in(NRETNIL_USERNAME,NRETNIL_PASSWORD)
    rescue StandardError => e
      get_error(__method__.to_s, e)
    end
  end

  def test_sign_in_as_user
    begin
      sign_in(NRETNIL_USERNAME,NRETNIL_PASSWORD)
    rescue StandardError => e
      get_error(__method__.to_s, e)
    end
  end

  def test_sign_out_as_user
    begin
      sign_in(NRETNIL_USERNAME,NRETNIL_PASSWORD)
      sign_out
    rescue StandardError => e
      get_error(__method__.to_s, e)
    end
  end

end