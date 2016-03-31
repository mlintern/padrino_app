require File.expand_path(File.dirname(__FILE__) + './../unit_test')

class String
  def is_uuid
    return !self.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/).nil?
  end
  def has_sym
    return !self.match(/[^a-zA-Z0-9]/).nil?
  end
end

class API < UnitTests
  
  def test_api
    response = get('/api')
    assert ( response.code == 200 && response["success"] ), "success was not returned"
  end

  def test_api_info
    response = get('/api/info')
    assert ( response.code == 200 && response["success"] ), "success was not returned"
  end

  def test_api_password
    # No Params
    response = get('/api/password')
    assert ( response.code == 200 && response["password"] && response["password"].length == 15 && response["phonetic"] && response["password"].has_sym ), "Password was not returned correctly."

    # Length Param
    response = get('/api/password?length=20')
    assert ( response.code == 200 && response["password"].length == 20 && response["password"].has_sym ), "Password was not 20 characters long."

    # Symbols Param is false
    response = get('/api/password?symbols=false')
    assert ( response.code == 200 && !response["password"].has_sym && response["password"].length == 15 ), "Password contains Symbols."

    # Symbols Param is false and Length Param
    response = get('/api/password?symbols=false&length=25')
    assert ( response.code == 200 && !response["password"].has_sym && response["password"].length == 25 ), "Password contains Symbols or was not 25 characters long."
  end

  def test_api_password_phrase
    response = get('/api/password/phrase')
    assert ( response.code == 200 && response["password"] && response["phonetic"] ), "password not provided"
  end

  def test_api_uuid
    response = get('/api/uuid')
    assert ( response.code == 200 && response.is_uuid ), "Response is not a uuid"
  end
end