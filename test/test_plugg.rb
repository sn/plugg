require 'minitest/autorun'
require 'plugg'

class PlugTest < Minitest::Test
  def setup
    Plugg.timeout(120)

    Plugg.source('./examples', {
      param:   'Parameter 1',
      another: 'Paramter 2'
    })
  end

  def test_registry_load
    assert_equal 1, Plugg.registry.length
  end

  def test_response
    response = Plugg.send(:test_method)

    assert_instance_of Array, response
  end

  def test_output
    response = Plugg.send(:test_method)

    assert_equal response.first[:plugin], "Demo Plugin"
  end
end
