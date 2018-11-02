# exchange_rate_history
Ruby gem for storing and calculating historical exchange rates.

This is my first time working with Ruby, so please be constructive in your criticism ;).


## Deployment

Developed for easy builds in Unix. Tested on Ubuntu 18.04 with Ruby version 2.3.1. This will attempt to install to the existing system Ruby installation (requires super user privileges).

```
$ git clone https://github.com/robsimpsondev/exchange_rate_history.git
$ cd exchange_rate_history
$ rake
```


## Testing

Tests are ran on installation and can be re-ran using `rake`, i.e.

```
$ rake test
```


## Usage

See `example/example.rb`, shown below:
```
# Make sure you have installed the exchange_rate_history gem - 
# run `rake build` first.
require 'exchange_rate_history'

# Initialise the default source (ECB 90 Day feed)
ExchangeRate.init_source()

# Use it...
puts "1.00 Euro yesterday was worth #{ExchangeRate.at(Date.today-1, 'EUR')} Euros."
puts "1.00 Euro yesterday was worth #{ExchangeRate.at(Date.today-1, 'USD')} Dollars."
puts "1.00 Euro thirty days ago was worth #{ExchangeRate.at(Date.today-30, 'JPY')} Yen."
puts "1.00 Yen thirty days ago was worth #{ExchangeRate.at(Date.today-30, 'EUR', 'JPY')} Euros."
puts "1.00 Dollar thirty days ago was worth #{ExchangeRate.at(Date.today-30, 'JPY', 'USD')} Yen."
```


## Data sources, storage and normalization

The class`ExchangeRateHistory::Source` represents a single source of exchange rates, and is by default the [ECB 90-day feed](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml). Each Source is implemented as a sub-class of `Source`, for example the aforementioned default is defined as `class ECB90DayFeed < ExchangeRateHistory::Source ... end` with a `:source_rate_parser` method defined.

The ECB source has a base currency of `'EUR'`, to which all of its rates are relative.

If an alternative data provider is used the source `source_counter_currency` must be set appropriately.

As mentioned above each sub-class of source *must* have a `:source_rate_parser` method defined that reads the source's response and returns a Hash of the form
```
=> {'date_str1' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... },
... 'date_str2' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... },
...
... 'date_strN' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... }}
```
which is used by the source's `:update_store` method.

Persistent data is saved in JSON format on disk at `local_store_abs_path` and is loaded into a Hash when the library class method `ExchangeRateHistory.init_source()` or `ExchangeRate.init_source()` is called (both classes are the same). The default implementation will create a local data store in the working directory.


## Notes on exchange rates.

It is assumed that the exchange rates manipulated using this library are reference rates; this is the case for the default implementation - the ECB's 90 day feed.

Therefore, this implementation allows cross-rates to be calculated from a single source in currencies other than the source's counter currency.

In general this may not be the case (and that is why rates are returned as strings in the current implementation).


## Scheduled updates

