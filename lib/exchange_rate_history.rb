class ExchangeRateHistory

  class << self

    attr_accessor :source


    def init_source(source_class_def = nil, source_data_store_path = nil)

      puts "ExchangeRateHistory: Initializing exchange rate source..."

      unless source_class_def
          require 'exchange_rate_history/sources/ECB90Day'
          self.source = ECB90Day.new(source_data_store_path)
      else
        path = "exchange_rate_history/sources/#{source_class_def[:file_name]}"
        puts "ExchangeRateHistory: Looking for source definition in ./#{path}" 
        require_relative "#{path}"
        self.source = eval("#{source_class_def[:class_name]}.new(source_data_store_path)")
      end

      puts "ExchangeRateHistory: Done."

      puts "ExchangeRateHistory: Updating local store and cache..."
      self.source.update_cache

      puts "ExchangeRateHistory: Done."
    end


    def at(date_obj, base_currency, counter_currency = nil)
      raise RuntimeError("Source not initialized, use .init_source(...)") unless self.source
      return self.source.get_rate_at(date_obj, base_currency) unless counter_currency
      return self.source.get_rate_at(date_obj, base_currency, counter_currency)
    end
  end

end


class ExchangeRate < ExchangeRateHistory
end