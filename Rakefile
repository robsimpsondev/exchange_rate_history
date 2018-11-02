task default: [:build, :test]

# Specifiy version to install from .gem
VERSION = "0.0.1"

task :build do
  `gem build exchange_rate_history.gemspec`
  `sudo gem install exchange_rate_history-#{VERSION}.gem`
end

task :test do
  ruby "test/test_exchange_rate_history.rb"
  ruby "test/exchange_rate_history/test_source.rb"
  ruby "test/exchange_rate_history/sources/test_ECB90Day.rb"
end