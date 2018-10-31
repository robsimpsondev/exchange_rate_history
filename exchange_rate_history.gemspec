Gem::Specification.new do |s|
  s.name        = 'exchange_rate_history'
  s.version     = '0.0.1'
  s.date        = '2018-10-23'
  s.summary     = "Stores and calculates historical exchange rates."
  s.description = "A ruby gem for storing and calculating foreign exchange rates. Integrates with the Money gem. This implementation uses 90-day FX rate data, published daily by the ECB."
  s.authors     = ["Rob Simpson"]
  s.email       = 'robsimpsondev@gmail.com'
  s.files       = ["lib/exchange_rate_history.rb", "lib/exchange_rate_history/source.rb", "lib/exchange_rate_history/sources/ECB90Day.rb"]
  s.homepage    =
    'http://rubygems.org/gems/exchange_rate_history'
  s.license       = 'MIT'


  s.add_development_dependency "rake", '~> 0'

  s.add_runtime_dependency "activesupport", '~> 5'
end