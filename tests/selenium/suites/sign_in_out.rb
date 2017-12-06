# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../watir_selenium')

# SignInOut Test Suite
class SignInOut < SeleniumTests
  def test_sign_in_as_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_sign_out_as_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    sign_out
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_sign_in_as_user
    sign_in(NRETNIL_USER_ONE_USERNAME, NRETNIL_USER_ONE_PASSWORD)
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_sign_out_as_user
    sign_in(NRETNIL_USER_ONE_USERNAME, NRETNIL_USER_ONE_PASSWORD)
    sign_out
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end
end
