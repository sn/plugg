Gem::Specification.new do |s|
  s.name        = 'plugg'
  s.version     = '1.0.1'
  s.date        = '2020-07-11'
  s.summary     = 'Plugg is a an asynchronous DSL for creating performant plugins'
  s.description = 'Plugg allows you to easily extend your application by providing you with a plug and play plugin framework'
  s.authors     = ['Sean Nieuwoudt']
  s.email       = 'sean@isean.co.za'
  s.files       = ['lib/plugg.rb']
  s.license     = 'GPL-2.0'
  s.homepage    = 'https://github.com/sn/plugg'
  
  s.add_development_dependency 'minitest', '~> 5.7', '>= 5.7.0'
  s.add_development_dependency 'rake', '~> 13.0'
end
