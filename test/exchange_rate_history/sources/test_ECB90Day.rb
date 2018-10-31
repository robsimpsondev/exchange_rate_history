require 'minitest/autorun'


require 'exchange_rate_history/sources/ECB90Day'


this_files_dir = File.dirname(__FILE__)
TEST_ABS_LOCAL_FILE_PATH = this_files_dir + '/../source_fixtures/ECB90Day_exchange_rate_data.json'


class TestECB90Day < Minitest::Test


  def setup
    @source = ECB90Day.new
  end


  def teardown
    # nothing to do
  end


  def test_source_rate_parser
    response = @source.get
    data_hash = @source.source_rate_parser(response)
    assert_equal Hash, data_hash.class
    refute_empty data_hash
  end

end