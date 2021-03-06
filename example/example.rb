# Make sure you have installed the exchange_rate_history gem - 
# run `rake build` first.
require 'exchange_rate_history'

# Initialise the default source (ECB 90 Day feed)
ExchangeRate.init_source()

# A data store has been created in the working directory.
# It's contents have been loaded into a cache.
# Use it...
puts "1.00 Euro yesterday was worth #{ExchangeRate.at(Date.today-1, 'EUR')} Euros."
puts "1.00 Euro yesterday was worth #{ExchangeRate.at(Date.today-1, 'USD')} Dollars."
puts "1.00 Euro thirty days ago was worth #{ExchangeRate.at(Date.today-30, 'JPY')} Yen."
puts "1.00 Yen thirty days ago was worth #{ExchangeRate.at(Date.today-30, 'EUR', 'JPY')} Euros."
puts "1.00 Dollar thirty days ago was worth #{ExchangeRate.at(Date.today-30, 'JPY', 'USD')} Yen."

# Update store, if you need to
ExchangeRate.source.update_store

# Update cache (this will update the store too if possible)
ExchangeRate.source.update_cache