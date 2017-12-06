# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + './../watir_selenium')

# Accounts Test Suite
class Accounts < SeleniumTests
  def test_accounts_pages_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    main_nav('Settings', 'Accounts')
    assert @driver.url.include?('/accounts'), 'Did not load Accounts page'

    wac(@driver.a(:css, '.new-user-tab'))
    assert @driver.url.include?('/accounts/new'), 'Did not load new user page'

    wac(@driver.a(:css, '.card-users-tab'))
    assert @driver.url.include?('/accounts/cards'), 'Did not load new user page'

    wac(@driver.a(:css, '.edit-user-tab'))
    assert @driver.url.include?('/accounts/edit'), 'Did not load new user page'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def update_and_clear_image
    @driver.text_field(:css, '.photo-url').set('http://www.nretnil.com/avatar/barrel.jpg')
    wac(@driver.button(:css, '.image-clear'))
    assert @driver.input(:css, '.photo-url').value.length.zero?, 'Image URL was not cleared'

    @driver.text_field(:css, '.photo-url').set('http://www.nretnil.com/avatar/barrel.jpg')
    wac(@driver.button(:css, '.image-update'))
    wait_till_page_loads
    check_for_success
  end

  def select_user(username)
    wac(@driver.a(:text, username))
    wait_till_page_loads
  end

  def test_edit_user_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    main_nav('Settings', 'Accounts')
    assert @driver.url.include?('/accounts'), 'Did not load Accounts page'
    select_user(NRETNIL_USER_ONE_USERNAME)
    update_and_clear_image
    wac(@driver.input(:css, '.user_save'))
    wait_till_page_loads
    check_for_success
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_profile_admin
    sign_in(NRETNIL_ADMIN_USERNAME, NRETNIL_ADMIN_PASSWORD)
    main_nav('Settings', 'Profile')
    assert @driver.url.include?('/accounts/edit/'), 'Did not load Profiled Settings page'
    update_and_clear_image
    wac(@driver.input(:css, '.user_save'))
    wait_till_page_loads
    check_for_success
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end

  def test_accounts_pages_negative
    sign_in(NRETNIL_USER_TWO_USERNAME, NRETNIL_USER_TWO_PASSWORD)
    @driver.goto(ENVIRONMENT_URL + '/accounts')
    assert !@driver.url.include?('/accounts'), 'Did load List Accounts page'

    @driver.goto(ENVIRONMENT_URL + '/accounts/new')
    assert !@driver.url.include?('/accounts/new'), 'Did load New Account page'

    @driver.goto(ENVIRONMENT_URL + '/accounts/cards')
    assert !@driver.url.include?('/accounts/cards'), 'Did load Accounts Card page'
  rescue StandardError => e
    get_error(__method__.to_s, e)
  end
end
