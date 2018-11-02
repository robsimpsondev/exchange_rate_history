require 'minitest/autorun'


require 'exchange_rate_history/sources/ECB90Day'
require_relative '../helpers'


this_files_dir = File.dirname(__FILE__)
TEST_LOCAL_STORE_ABS_PATH = this_files_dir + '/../source_fixtures/ECB90Day_exchange_rate_data.json'


class TestECB90Day < Minitest::Test

  def test_source_rate_parser
    source = suppress_output do
      ECB90Day.new(TEST_LOCAL_STORE_ABS_PATH)
    end
    response = source.get
    data_hash = source.source_rate_parser(response)
    assert_equal Hash, data_hash.class
    refute_empty data_hash
  end

end