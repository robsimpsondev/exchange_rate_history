require 'active_support/core_ext/hash'


require 'exchange_rate_history/source'

class ECB90Day < ExchangeRateHistory::Source
  # This is the default class of exchange rate source
  # for the ExchangeRateHistory and ExchangeRate classes.
  # All that needs to be defined is a :remote_rate_parser method
  # that returns the :cached_data.

  def initialize(local_store_abs_path = nil)
    unless local_store_abs_path
      local_store_abs_path = Dir.pwd + "/ECB90Day_exchange_rate_history.json"
      $stderr.puts "WARNING: Source data store assumed to be at #{local_store_abs_path}"
    end
    super(
      source_url = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml",
      source_counter_currency = 'EUR',
      local_store_abs_path = local_store_abs_path
    )
  end

  def source_rate_parser(source_response = @response)

    # convert source xml into Ruby hash
    source_hash = Hash.from_xml(source_response.body)

    # isolate rates
    rates = source_hash["Envelope"]["Cube"]["Cube"]

    # create new hash
    data_hash = Hash.new
    data_hash[:last_updated] = DateTime.now.iso8601
    data_hash[:source_url] = @source_url

    # fill in rates for each time
    rates.each do |elem|
      inner_hash = Hash.new()
      data_hash.merge!("#{elem['time']}" => inner_hash)
      elem['Cube'].each do |rate_hash|
        inner_hash.merge!("#{rate_hash['currency']}" => "#{rate_hash['rate']}")
      end
    end
    
    return data_hash
  end

end