class SeleniumTests < Minitest::Test

  def screenshot (name)
    time = Time.new
    @driver.screenshot.save './screenshots/' + name + '_' + time.strftime('%Y%m%d_%H%M%S') + '.png'  # @driver.driver.save_screenshot('screenshots/' + name + '_' + time.strftime('%Y%m%d_%H%M%S') + '.png')
  end

  def get_error (test_name, error = nil)
    puts error.message
    puts error.backtrace
    screenshot(test_name)
    raise
  end

  def wait_till_page_loads ()
    @driver.body(:css, '.nretnil-document-ready').wait_until_present
  end

  def sign_in (username, password)
    @driver.goto ENVIRONMENT_URL
    @driver.text_field(:id, "username").set(username)
    @driver.text_field(:id, "password").set(password)
    @driver.button(:css, '.sign-in-btn').click
    wait_till_page_loads
    assert !@driver.url.include?('/sessions/new')
  end

  def sign_out
    wait_till_page_loads
    @driver.a(:css, '.user-menu-dropdown').wait_until_present
    @driver.a(:css, '.user-menu-dropdown').click
    @driver.a(:css, '.logout-btn').wait_until_present
    @driver.a(:css, '.logout-btn').click
    wait_till_page_loads
    assert @driver.url.include?('/sessions/new')
  end

  def main_nav(option)
    @driver.a(:css, '.main-menu-dropdown').wait_until_present
    @driver.a(:css, '.main-menu-dropdown').click
    @driver.a(:text, option).wait_until_present
    @driver.a(:text, option).click
    wait_till_page_loads
  end

  def user_nav(option)
    @driver.a(:css, '.user-menu-dropdown').wait_until_present
    @driver.a(:css, '.user-menu-dropdown').click
    @driver.a(:text, option).wait_until_present
    @driver.a(:text, option).click
    wait_till_page_loads
  end

end