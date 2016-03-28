#!/bin/env ruby
# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + './../watir-selenium')

class Navigation < SeleniumTests

  def test_main_menu
    begin
      sign_in(NRETNIL_USERNAME,NRETNIL_PASSWORD)
      main_nav("Home")
      assert @driver.div(:css, ".new-features").exists?, "Did not load Home page"
      main_nav("PL Translator")
      assert @driver.url.include?('/translator'), "Did not load PL Translator page"
      main_nav("Curl API Tool")
      assert @driver.url.include?('/curl'), "Did not load Curl API Tool page"
    rescue StandardError => e
      get_error(__method__.to_s, e)
    end
  end

  def test_user_menu
    begin
      sign_in(NRETNIL_USERNAME,NRETNIL_PASSWORD)
      user_nav("Accounts")
      assert @driver.url.include?('/accounts'), "Did not load Accounts page"
      user_nav("Profile Settings")
      assert @driver.url.include?('/accounts/edit/'), "Did not load Profiled Settings page"
    rescue StandardError => e
      get_error(__method__.to_s, e)
    end
  end

end