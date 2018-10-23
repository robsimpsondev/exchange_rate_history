class ExchangeRateHistory
  def self.puts_rate(source = nil)
    rate_finder = RateFinder.new(source)
    puts rate_finder.find_rate()
  end
end

require 'exchange_rate_history/rate_finder'