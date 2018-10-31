require 'resolv'
require 'minitest/autorun'

require 'exchange_rate_history/source'


# TODO: remove network dependency from testing and stub relevent libraries



# Make sure the following file exists before testing
this_files_dir = File.dirname(__FILE__)
TEST_ABS_LOCAL_FILE_PATH_NO_DATA = this_files_dir + '/source_fixtures/empty_data_file'
TEST_ABS_LOCAL_FILE_PATH_GOOD_DATA = this_files_dir + '/source_fixtures/Source.json'
TEST_ABS_LOCAL_FILE_PATH_BAD_DATA = this_files_dir + '/source_fixtures/Source.json_corrupted'
TEST_TEMP_FILE = this_files_dir + '/source_fixtures/temp'  # Careful, this gets removed from the filesystem

TEST_SOURCE_URL = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"

TEST_BASE_CURRENCY = 'XXX'


# Temporarily redirects STDOUT and STDERR to /dev/null
# but does print exceptions should they occur.
# https://gist.github.com/moertel/11091573
def suppress_output
  original_stdout, original_stderr = $stdout.clone, $stderr.clone
  $stderr.reopen File.new('/dev/null', 'w')
  $stdout.reopen File.new('/dev/null', 'w')
  yield
ensure
  $stdout.reopen original_stdout
  $stderr.reopen original_stderr
end


class SourceTest < Minitest::Test

  def setup
    # nothing to do
  end


  def teardown
    # nothing to do
  end


  def test_check_local_true_for_existing_file
    source = ExchangeRateHistory::Source.new(TEST_SOURCE_URL,
      TEST_BASE_CURRENCY,
      TEST_ABS_LOCAL_FILE_PATH_NO_DATA
    )
    assert source.check_local
    assert source.local_file_flag
  end


  def test_check_local_raises_for_nonexistant_file
    bad_local_source = suppress_output do
      ExchangeRateHistory::Source.new(
        TEST_SOURCE_URL,
        'a/file/that/doesnt_exist/anywhere_at.all',
        TEST_BASE_CURRENCY
      )
    end
    assert_raises(LocalSourceNotFoundError) do
      bad_local_source.check_local
    end
  end


  def test_check_remote_success_returns_true
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_BASE_CURRENCY,
      TEST_ABS_LOCAL_FILE_PATH_NO_DATA
    )
    # first check we have the internet for the tests
    if internet_connection?
      assert source.check_remote
      assert source.remote_file_flag
    else
      raise "Cannot access DNS servers - are you connected to the internet?"
    end
  end


  def test_check_remote_no_internet_causes_connection_error
    # See TODO at top.
  end


  def test_check_remote_fails_causes_remote_source_error
    bad_remote_source = suppress_output do
      ExchangeRateHistory::Source.new(
        'https://this/doesnt/exist/file.RANDOM_10375617',
        TEST_BASE_CURRENCY,
        TEST_ABS_LOCAL_FILE_PATH_NO_DATA
      )
    end
    assert_raises(RemoteSourceError) do
      bad_remote_source.check_remote
    end
  end


  def test_check_local_file_not_found_checks_remote
    no_local_source = suppress_output do
      ExchangeRateHistory::Source.new(
        TEST_SOURCE_URL,
        TEST_ABS_LOCAL_FILE_PATH_NO_DATA + "_no_such_file",
        TEST_BASE_CURRENCY
      )
    end
    assert_equal false, no_local_source.local_file_flag
    assert_equal true, no_local_source.remote_file_flag
  end


  def test_get_succeeds_with_good_remote_url
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_BASE_CURRENCY,
      TEST_ABS_LOCAL_FILE_PATH_NO_DATA
    )
    source.get
  end


  def test_get_fails_returns_error
    bad_remote_source = suppress_output do
      ExchangeRateHistory::Source.new(
        'https://this/doesnt/exist/file.RANDOM_10375617',
        TEST_BASE_CURRENCY,
        TEST_ABS_LOCAL_FILE_PATH_NO_DATA,
      )
    end
    assert_raises(Exception) do
      bad_remote_source.get
    end
  end


  def test_load_succeeds_on_good_local_file
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_BASE_CURRENCY,
      TEST_ABS_LOCAL_FILE_PATH_GOOD_DATA
    )
    source.load_cache_from_store
    refute_empty source.cache
  end


  def test_load_fails_with_empty_local_data_raises_local_source_error
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_BASE_CURRENCY,
      TEST_ABS_LOCAL_FILE_PATH_NO_DATA
    )
    assert_raises(LocalSourceError) do
      source.load_cache_from_store
    end
  end


  def test_save_feed_data_with_nonexistant_store_creates_one
    source = suppress_output do
      ExchangeRateHistory::Source.new(
        TEST_SOURCE_URL,
        TEST_BASE_CURRENCY,
        TEST_TEMP_FILE
      )
    end
    pn = Pathname.new(source.local_store_abs_path)
    assert_equal true, pn.exist?
    `rm #{TEST_TEMP_FILE}`
  end


  def test_save_feed_data_with_populated_store_same_data
  end


  def test_save_feed_data_populated_store_new_data
  end


  def test_init_no_sources_raises_error
    assert_raises(RuntimeError) do
      source = suppress_output do
        ExchangeRateHistory::Source.new(
        "https://this/doesnt/exist/file.RANDOM_10375617",
        "no-such.file",
        TEST_BASE_CURRENCY
      )
      end
    end
  end

end