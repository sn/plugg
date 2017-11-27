class DemoPlugin
  def test_method
    puts "Inside test_method"
  end

  def setup(p)
    @params = p
  end

  def to_s
    "Demo Plugin"
  end
end
