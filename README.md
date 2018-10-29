# exchange_rate_history
Ruby gem for storing and calculating historical exchange rates. Integrates with the Money gem.


## Deployment

Developed for easy builds in Unix. Tested on Ubuntu 18.04 with Ruby version 2.3.1. This will attempt to install to the existing system Ruby installation (requires super user priveleges).

```
$ rake
```


## Testing

Tests are ran on installation and can be re-ran using `rake`, i.e.

```
$ rake test
```


## Usage

There are two classes that provide an interface to this library:
 - `ExchangeRate`, for calculating rates on a given day using class method `:at`
 - `ExchangeRateHistory`, for calculating rates accross a date range using class method `:from`
 
Examples:
```
irb> require 'exchange_rate_history'
irb> ExchangeRateHistory.init_source()  # Default source
irb> rate = ExchangeRate.at(Date.today,'GBP','USD')  # => a Fixnum
irb> dates_with_rates = ExchangeRateHistory.from(Date.today - #FOO, Date.today, 'GBP', 'USD')  # => { Date1: rate1, Date2: rate2, ...}
```


## Data sources, storage and normalization

The class`ExchangeRateHistory::Source` represents a single source of exchange rates, and is by default the [ECB 90-day feed](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml). Each Source is implemented as a sub-class of `Source`, for example the aforementioned default is defined as `class ECB90DayFeed < ExchangeRateHistory::Source ... end`.

The ECB source has a base currency of `'EUR'`, to which all of its rates are relative.

If an alternative data provider is used the source `base_currency` must be set appropriately.

The `Source` object and its child classes work using the following methods:
```
irb> source = ExchangeRateHistory::Source.new(source_url, abs_local_file_path, base_currency)  # initialize
irb> source.check_local   # checks for local data file at abs_local_file_path
irb> source.load          # reads the saved data from disk into volatile memory (the "cache")
irb> source.check_remote  # checks a successful response is available from source_url
irb> source.get           # goes to the source url and gets the response
irb> source.update        # updates data feed using source_url response
irb> source.save          # writes feed data to abs_local_file_path
```

The default implementation of `source.save` will create a data file in `data/` called `<Source.name>_exchange_rate_data.xml` from which data will be loaded during source initialization, if possible.

Each source object *must* also have a `:source_rate_parser` method defined, that reads the source's response and returns a Hash of the form
```
=> {'date_str1' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... },
... 'date_str2' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... },
...
... 'date_strN' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... }}
```
which is used by `source.update`.

Persistant data is saved in XML format on disk at `abs_local_file_path` and is loaded into to a Hash when the library class method `ExchangeRateHistory.init_source()` is called.
