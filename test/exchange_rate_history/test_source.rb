require 'resolv'

require 'minitest/autorun'

require 'exchange_rate_history/source'


# TODO: remove network dependency from testing and stub relevent libraries
# TODO: redirect stderr to log for bad inits


# Make sure the following file exists before testing
this_files_dir = File.dirname(__FILE__)
TEST_ABS_LOCAL_FILE_PATH = this_files_dir + '/source_fixtures/test_data.xml'


class SourceTest < Minitest::Test

  def setup
    @source = ExchangeRateHistory::Source.new(
      abs_local_file_path: TEST_ABS_LOCAL_FILE_PATH
    )
  end


  def teardown
    # nothing to do
  end


  def test_check_local_true_for_existing_file
    assert @source.check_local
    assert @source.local_file_flag
  end


  def test_check_local_raises_for_nonexistant_file
    bad_local_source = ExchangeRateHistory::Source.new(
      abs_local_file_path: 'a/file/that/doesnt_exist/anywhere_at.all'
    )
    assert_raises(LocalSourceNotFoundError) do
      bad_local_source.check_local
    end
  end


  def test_check_remote_success_returns_true
    # first check we have the internet for the tests
    if internet_connection?
      assert @source.check_remote
      assert @source.remote_file_flag
    else
      raise "Cannot access DNS servers - are you connected to the internet?"
    end
  end


  def test_check_remote_no_internet_causes_connection_error
    # See TODO at top.
  end


  def test_check_remote_fails_causes_remote_source_error
    bad_remote_source = ExchangeRateHistory::Source.new(
      abs_local_file_path: TEST_ABS_LOCAL_FILE_PATH,
      source_url:          'https://this/doesnt/exist/file.RANDOM_10375617'
    )
    assert_raises(RemoteSourceError) do
      bad_remote_source.check_remote
    end
  end


  def test_check_local_file_not_found_checks_remote
    no_local_source = ExchangeRateHistory::Source.new(
      abs_local_file_path: TEST_ABS_LOCAL_FILE_PATH + "_no_such_file"
    )
    assert_equal false, no_local_source.local_file_flag
    assert_equal true, no_local_source.remote_file_flag
  end


  def test_get_succeeds_with_good_remote_url
    @source.get
  end


  def test_get_fails_returns_error
    bad_remote_source = ExchangeRateHistory::Source.new(
      abs_local_file_path: TEST_ABS_LOCAL_FILE_PATH,
      source_url: 'https://this/doesnt/exist/file.RANDOM_10375617'
    )
    assert_raises(Exception) do
      bad_remote_source.get
    end
  end


  def test_rate_parser_succeeds_on_good_remote_file
  end


  def test_rate_parser_fails_with_bad_data_raises_remote_source_error
  end


  def test_rate_parser_succeeds_on_good_local_file
  end


  def test_rate_parser_fails_with_bad_local_data_raises_local_source_error
  end


  def test_update_from_zero_cached_data
  end


  def test_update_cache_with_existing_data
  end


  def test_update_with_bad_data_raises_remote_source_error
  end


  def test_save_existing_data_with_new_data
  end


  def test_save_existing_data_with_old_data_no_change
  end


  def test_init_default_source_for_test_no_errors
  end


  def test_init_default_no_connection_to_remote_uses_existing_file_prints_warning
  end


  def test_init_default_no_connection_no_exisiting_file__causes_error_and_useful_message
  end

end