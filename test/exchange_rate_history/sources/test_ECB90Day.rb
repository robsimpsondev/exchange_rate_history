require 'minitest/autorun'


require 'exchange_rate_history/sources/ECB90Day'


this_files_dir = File.dirname(__FILE__)
TEST_ABS_LOCAL_FILE_PATH = this_files_dir + '/../source_fixtures/ECB90Day_exchange_rate_data.json'


class ECB90DayTest < Minitest::Test

  def setup
    @source = ECB90Day.new
  end


  def teardown
    # nothing to do
  end


  def test_source_rate_parser
    assert @source.check_remote
    @source.get
    assert_equal({}, @source.source_rate_parser(@source.response))
  end

end