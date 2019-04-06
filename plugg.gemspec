Gem::Specification.new do |s|
  s.name        = 'plugg'
  s.version     = '1.0.0'
  s.date        = '2019-04-06'
  s.summary     = 'Plugg is an independent plugin creation framework and DSL'
  s.description = 'Plugg allows you to easily extend your application by providing you with a bolt-on plugin framework'
  s.authors     = ['Sean Nieuwoudt']
  s.email       = 'sean@isean.co.za'
  s.files       = ['lib/plugg.rb']
  s.license     = 'GPL-2.0'
  s.homepage    = 'https://github.com/SeanNieuwoudt/plugg'

  s.add_development_dependency 'minitest', '~> 5.7', '>= 5.7.0'
  s.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
end
