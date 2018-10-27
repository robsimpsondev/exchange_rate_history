# exchange_rate_history
Ruby gem for storing and calculating historical exchange rates. Integrates with the Money gem.


## Deployment

Developed for quick building in Unix. Tested on Ubuntu 18.04.

```
$ bundle #TODO
$ rake   #TODO
```


## Testing

Tests are ran on installation and can be re-ran using `rake`, i.e.

```
$ rake
```


## Usage

There are two classes that provide an interface to this library:
 - `ExchangeRate`, for calculating rates on a given day using class method `:at`
 - `ExchangeRateHistory`, for calculating rates accross a date range using class method `:from`
 
Examples:
```
irb> require 'erh'
irb> ExchangeRateHistory.init_source()  # Default source
irb> rate = ExchangeRate.at(Date.today,'GBP','USD')  # => a Fixnum
irb> dates_with_rates = ExchangeRateHistory.from(Date.today - #FOO, Date.today, 'GBP', 'USD')  # => { Date1: rate1, Date2: rate2, ...}
```


## Data sources, storage and normalization

There is a class whose objects contains a single source of exchange rates called `ExchangeRateHistory::Source`, which by default is the [ECB 90-day feed](https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml). Each source is implemented as a sub-class, for example teh default is defined `class ECB90DayFeed < ExchangeRateHistory::Source ... end`.

The ECB source has a base currency of EUR, to which all other rates are relative.

If an alternative data provider is used the source `base_currency` must be set appropriately.

For a Source object to work the following must methods be defined:
```
irb> source = ExchangeRateHistory::Source.new(source_uri, abs_local_file_path, base_currency)  # initialize
irb> source.check_local   # check for abs_local_file_path
irb> source.load          # reads the saved data from disk into volatile memory ("cache")
irb> source.check_remote  # checks a response is available from source_uri
irb> source.get           # goes to the source uri and gets the file
irb> source.update        # updates the cache using source_uri file data
irb> source.save          # writes cached data to abs_local_file_path
```

The default source looks for an .xml file at the source uri and parses it into memory. A new file is created called `<Source.name>_exchange_rate_data.xml` from which data will be loaded first during source initialization, if possible.

Each source object must also have a `:rate_parser` method defined, that reads the data and returns a Hash of the form
```
=> {'date_str1' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... },
... 'date_str2' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... },
...
... 'date_strN' => {'GBP' => 0.9, 'USD' => 1.1, 'XXX' => 100.123, ... }}
```
which is used by `source.update`.

Persistant data is saved in XML format on disk at `abs_local_file_path`.
