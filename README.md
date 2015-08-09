## Plugg: A bolt-on Ruby plugin framework

[![Gem Version](https://badge.fury.io/rb/plugg.svg)](https://rubygems.org/gems/plugg)
[![Build Status](https://travis-ci.org/Wixel/Plugg.svg)](https://travis-ci.org/Wixel/Plugg)

Simple & efficient plugin framework for Ruby applications.

Plugg automatically loads all plugins from the paths you specify and creates instances of each inside an internal registry. When you send messages to Plugg, it relays those messages to each plugin that can respond to the message. Once all plugins have responded, it hands back an array containing the output from each plugin.

Any Ruby class can be used as a plugin because there are no external dependencies to implement.

Requirements
-----------------

It's recommend that you use Ruby 2.0.0 or higher.

Installation
-----------------

    gem install plugg

Getting Started
-----------------

It's really simple to get Plugg running, after the installation, you simple require it and set the source directory where the plugin classes should be loaded from. You can also specify more than one source directory by passing an array to the *Plugg.source(path)* method instead of a string path. One caveat is that plugin class names should match the plugin file names exactly.

```ruby
require 'plugg'

Plugg.source('./plugins') # or Plugg.source(['./plugins1', './plugins2'])

result = Plugg.send(:test_method, "a parameter")
```

In the above example, you are sending the *:test_method* message to each plugin class in the loaded registry and returning the output from each of these calls in an array (result).

The *:test_method* message should correspond to a method with the same name in the plugin class:

    cat DemoPlugin.rb

```ruby
class DemoPlugin
  def test_method(param)
    puts "Inside test_method with #{param}"
  end

  def to_s
    "Demo Plugin"
  end
end
```

You can also pass any number of arguments to the plugin methods when they are called:

```ruby
result = Plugg.send(:test_method, arg1, arg2 arg3, etc)
```

Plugin Parameters
-----------------

If you wish to share default parameters or arguments with your plugins, you can do so by passing a hash as the second parameter of _Plugg.source()_.

```ruby
Plugg.source("./plugins", {
  :param1 => "A value",
  :param2 => "Another value"
})
```

To be able to inject the parameter hash from the registry into your plugin class, you need to implement a _set_params(p)_ method:

```ruby
class DemoPlugin
  def test_method(param)
    puts "Inside test_method with #{param}"
  end

  def set_params(p)
    @params = p
  end

  def to_s
    "Demo Plugin"
  end
end
```

Return value
-----------------

You can return anything you need from your plugin methods and can easily access the return data inspecting the result from *Plugg.send()* method:

```ruby
[
  {
    :plugin => "Demo Plugin",
    :return => nil,
    :timing => 0.013
  }
]
```

The power of Plugg starts revealing itself when you are running many plugins with many different methods.

Running the tests
-----------------

To test the current stable version of Plugg, simply run:

    rake test

License
-----------------

Please see [LICENSE](https://github.com/Wixel/Plugg/blob/master/LICENSE) for licensing details.

Author
-----------------

Sean Nieuwoudt, [@seannieuwoudt](https://twitter.com/seannieuwoudt) / [http://isean.co.za](http://isean.co.za) / [https://wixelhq.com](https://wixelhq.com)
