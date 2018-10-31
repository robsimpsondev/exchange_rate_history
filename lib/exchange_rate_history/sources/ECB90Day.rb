require 'exchange_rate_history/source'

class ECB90Day < ExchangeRateHistory::Source
  # This is the default class of exchange rate source
  # for the ExchangeRateHistory and ExchangeRate classes.
  # All that needs to be defined is a :remote_rate_parser method
  # that returns the :cached_data.

  def initialize(local_store_abs_path = nil)
    unless local_store_abs_path
      local_store_abs_path = Dir.pwd + "/ECB90Day_exchange_rate_history.json"
      $stderr.puts "Source data store assumed to be at #{local_store_abs_path}"
    end
    super(
      source_url = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml",
      base_currency = 'EUR',
      local_store_abs_path = local_store_abs_path
    )
  end

  def source_rate_parser(source_response)
    data_hash = {}
    return data_hash
  end
end