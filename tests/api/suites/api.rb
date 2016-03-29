require File.expand_path(File.dirname(__FILE__) + './../unit_test')

class API < UnitTests

  def get(url)
    return HTTParty.get(@SERVER+url)
  end
  
  def test_api
    result = get('/api')
    assert result["success"]
  end

  def test_api_info
    result = get('/api/info')
    assert result["success"]
  end
end