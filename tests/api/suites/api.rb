require File.expand_path(File.dirname(__FILE__) + './../unit_test')

class String
  def is_uuid
    return !self.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/).nil?
  end
  def has_sym
    return self.match(/[a-zA-Z0-9]/).nil?
  end
end

class API < UnitTests
  
  def test_api
    result = get('/api')
    assert result["success"]
  end

  def test_api_info
    result = get('/api/info')
    assert result["success"]
  end

  def test_api_password
    # No Params
    result = get('/api/password')
    assert result["password"], "Password was not returned."

    # Length Param
    result = get('/api/password?length=20')
    assert result["password"].length == 20, "Password was not 20 characters long."

    # Symbols Param
    result = get('/api/password?symbols=false')
    assert !result["password"].has_sym, "Password contains Symbols."

    # Symbols Param and Length Param
    result = get('/api/password?symbols=false&length=25')
    assert ( ( !result["password"].has_sym ) && ( result["password"].length == 25 ) ), "Password contains Symbols or was not 25 characters long."
  end

  def test_api_password_phrase
    result = get('/api/password/phrase')
    assert result["password"]
  end

  def test_api_uuid
    result = get('/api/uuid')
    assert result.is_uuid
  end
end