# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../watir_selenium')

# Navigation Test Suite
class Navigation < SeleniumTests
  def test_main_menu_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    main_nav('Home')
    assert @driver.div(:css, '.api-enpoints').exists?, 'Did not load Home page'

    main_nav('Tools', 'PL Translator')
    assert @driver.url.include?('/translator'), 'Did not load PL Translator page'

    main_nav('Tools', 'Curl API')
    assert @driver.url.include?('/curl'), 'Did not load Curl API Tool page'

    main_nav('Settings', 'Accounts')
    assert @driver.url.include?('/accounts'), 'Did not load Accounts page'

    main_nav('Settings', 'Profile')
    assert @driver.url.include?('/accounts/edit/'), 'Did not load Profiled Settings page'

    main_nav('Tools')
    assert !@driver.a(:text, 'To Dos').exists?, 'ToDos link exists'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_main_menu_negative
    sign_in(NRETNIL_USER_TWO_USERNAME, NRETNIL_USER_TWO_PASSWORD)
    @driver.goto(ENVIRONMENT_URL + '/accounts')
    wait_till_page_loads
    assert !@driver.url.include?('/accounts'), 'Loaded accounts page when it should not have'

    @driver.goto(ENVIRONMENT_URL + '/curl')
    wait_till_page_loads
    assert !@driver.url.include?('/curl'), 'Loaded curl page when it should not have'

    @driver.goto(ENVIRONMENT_URL + '/translator')
    wait_till_page_loads
    assert !@driver.url.include?('/translator'), 'Loaded translator page when it should not have'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_todo
    sign_in(NRETNIL_USER_ONE_USERNAME, NRETNIL_USER_ONE_PASSWORD)
    main_nav('Tools', 'To Dos')
    assert @driver.div(:css, '.modal-header').exists?, 'Modal did not Load'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end
end
