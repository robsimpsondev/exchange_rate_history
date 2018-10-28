require 'exchange_rate_history/source'

class ECB90Day < ExchangeRateHistory::Source
  # This is the default class of exchange rate source
  # for the ExchangeRateHistory and ExchangeRate classes.
  # All that needs to be defined is a :remote_rate_parser method
  # that returns the :cached_data.

  def source_rate_parser(source_response)
    data_hash = {}
    return data_hash
  end
end