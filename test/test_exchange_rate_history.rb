require 'minitest/autorun'
require 'exchange_rate_history'

class ExchangeRateHistoryTest < Minitest::Test

  def setup
    # nothing
  end

  def teardown
    # nothing
  end

  def test_output_with_default_source
    out, err = capture_io do
      ExchangeRateHistory.puts_rate
    end
    assert_empty err
    assert_equal "1.00\n", out 
  end

  def test_output_with_unknown_source
    out, err = capture_io do
      ExchangeRateHistory.puts_rate "unknown_source"
    end
    assert_empty err
    assert_equal "rate source not found\n", out
  end
end