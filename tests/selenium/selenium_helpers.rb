#!/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# SeleniumTest Helpers
class SeleniumTests < Minitest::Test
  def screenshot(name)
    time = Time.new
    @driver.screenshot.save './screenshots/' + name + '_' + time.strftime('%Y%m%d_%H%M%S') + '.png' # @driver.driver.save_screenshot('screenshots/' + name + '_' + time.strftime('%Y%m%d_%H%M%S') + '.png')
  end

  def get_error(test_name, error = nil)
    puts error.message
    # puts error.backtrace
    screenshot(test_name)
    raise
  end

  def wait_till_page_loads
    @driver.body(:css, '.nretnil-document-ready').wait_until_present
  end

  def wac(el)
    el.wait_until_present
    el.click
  end

  alias wait_and_click wac

  def sign_in(username, password)
    @driver.goto ENVIRONMENT_URL
    wait_and_click(@driver.a(:css, '.login-btn'))
    @driver.text_field(:id, 'username').set(username)
    @driver.text_field(:id, 'password').set(password)
    wait_and_click(@driver.button(:css, '.sign-in-btn'))
    wait_till_page_loads
    assert !@driver.url.include?('/sessions/new')
  end

  def sign_out
    wait_till_page_loads
    wait_and_click(@driver.a(:css, '.user-menu-toggle'))
    wait_and_click(@driver.a(:css, '.logout-btn'))
    wait_till_page_loads
    assert @driver.url == ('http://' + ENVIRONMENT_URL + '/')
  end

  def main_nav(section, option = nil)
    wait_and_click(@driver.a(:css, '.menu-trigger'))
    wait_and_click(@driver.a(:text, section))
    wait_and_click(@driver.a(:text, option)) unless option.nil?
    wait_till_page_loads
  end
end
