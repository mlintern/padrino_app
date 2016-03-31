require File.expand_path(File.dirname(__FILE__) + './../unit_test')

class APITranslator < UnitTests

  AUTH = { :username => "administrator", :password => "password" }
  
  def test_api_translator
    response = get('/api/translator')
    assert ( response.code == 403 && !response["success"] ), "Was not Forbidden"

    response = get('/api/translator', AUTH)
    assert ( response.code == 200 && response["success"] && response["info"].length > 0 )
  end

  def test_api_translator_install
    response = post('/api/translator/install')
    assert ( response.code == 400 && !response["success"] ), "App Installed when it should not have"
  end

end