#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../watir-selenium')

# SignInOut Test Suite
class SignInOut < SeleniumTests
  def test_sign_in_as_admin
    sign_in(NRETNIL_USERNAME, NRETNIL_PASSWORD)
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_sign_in_as_user
    sign_in(NRETNIL_USERNAME, NRETNIL_PASSWORD)
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_sign_out_as_user
    sign_in(NRETNIL_USERNAME, NRETNIL_PASSWORD)
    sign_out
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end
end
