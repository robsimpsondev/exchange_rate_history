Gem::Specification.new do |s|
  s.name        = 'exchange_rate_history'
  s.version     = '0.0.1'
  s.date        = '2018-10-23'
  s.summary     = "Stores and calculates historical exchange rates."
  s.description = "A ruby gem for storing and calculating foreign exchange rates. Integrates with the Money gem. This implementation uses 90-day FX rate data, published daily by the ECB."
  s.authors     = ["Rob Simpson"]
  s.email       = 'robsimpsondev@gmail.com'
  s.files       = ["lib/exchange_rate_history.rb", "lib/exchange_rate_history/source.rb"]
  s.homepage    =
    'http://rubygems.org/gems/exchange_rate_history'
  s.license       = 'MIT'
end