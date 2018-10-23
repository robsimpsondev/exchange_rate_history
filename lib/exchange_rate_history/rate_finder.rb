class ExchangeRateHistory::RateFinder
  def initialize(source)
    @source = source
  end

  def find_rate
    case @source
    when nil
      "1.00"
    else
      "rate source not found"
    end
  end
end