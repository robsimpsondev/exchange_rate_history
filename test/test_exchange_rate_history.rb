require 'minitest/autorun'


require 'exchange_rate_history'
require 'exchange_rate_history/source'
require 'exchange_rate_history/sources/ECB90Day'
require_relative 'exchange_rate_history/helpers.rb'


class ExchangeRateHistoryTest < Minitest::Test

  def setup
    # nothing
  end

  def teardown
    # nothing
  end

  def test_init_source_with_default_creates_ECB90Day
    suppress_output do
      ExchangeRateHistory.init_source()
    end
    assert_equal ECB90Day, ExchangeRateHistory.source.class
  end

  def test_init_source_with_defined_source_creates_it
    source_class_def = {:file_name => "ECB90Day.rb",
                        :class_name => "ECB90Day"}
    suppress_output do
      ExchangeRateHistory.init_source(source_class_def)
    end
    assert_equal ECB90Day, ExchangeRateHistory.source.class
  end
end