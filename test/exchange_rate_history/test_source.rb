require 'resolv'
require 'minitest/autorun'


require 'exchange_rate_history/source'
require_relative 'helpers.rb'


# TODO: remove network dependency from testing and stub relevent libraries


this_files_dir = File.dirname(__FILE__)
TEST_LOCAL_STORE_ABS_PATH_NO_DATA = this_files_dir + '/source_fixtures/empty_data_file'
TEST_LOCAL_STORE_ABS_PATH_BAD_DATA = this_files_dir + '/source_fixtures/Source.json_corrupted'
TEST_TEMP_FILE = this_files_dir + '/source_fixtures/temp'  # Careful, this gets removed from the filesystem

# This file contains a sample from ECB feed
TEST_LOCAL_STORE_ABS_PATH_GOOD_DATA = this_files_dir + '/source_fixtures/Source.json'
TEST_DATE_IN_SOURCE_JSON = Date.parse("2018-10-30")

# This is the feed used for testing
TEST_SOURCE_URL = "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"
TEST_COUNTER_CURRENCY = 'EUR'


# Stub :source_rate_parser as it is only defined in child classes.
class ExchangeRateHistory::Source
  def source_rate_parser(an_arg)
    return {"test" => "hash"}
  end
end


class TestSource < Minitest::Test

  def setup
    # nothing to do
  end


  def teardown
    # nothing to do
  end


  def test_check_local_true_for_existing_file
    source = ExchangeRateHistory::Source.new(TEST_SOURCE_URL,
      TEST_COUNTER_CURRENCY,
      TEST_LOCAL_STORE_ABS_PATH_NO_DATA
    )
    assert source.check_local
    assert source.local_file_flag
  end


  def test_check_local_raises_for_nonexistant_file
    bad_local_source = suppress_output do
      ExchangeRateHistory::Source.new(
        TEST_SOURCE_URL,
        TEST_COUNTER_CURRENCY,
        'no-such.file',
      )
    end
    assert_raises(LocalSourceNotFoundError) do
      bad_local_source.check_local
    end
  end


  def test_check_remote_success_returns_true
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_COUNTER_CURRENCY,
      TEST_LOCAL_STORE_ABS_PATH_NO_DATA
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
        TEST_COUNTER_CURRENCY,
        TEST_LOCAL_STORE_ABS_PATH_NO_DATA
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
        TEST_COUNTER_CURRENCY,
        "no-such.file",
      )
    end
    assert_equal false, no_local_source.local_file_flag
    assert_equal true, no_local_source.remote_file_flag
  end


  def test_get_succeeds_with_good_remote_url
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_COUNTER_CURRENCY,
      TEST_LOCAL_STORE_ABS_PATH_NO_DATA
    )
    source.get
  end


  def test_get_fails_returns_error
    bad_remote_source = suppress_output do
      ExchangeRateHistory::Source.new(
        'https://this/doesnt/exist/file.RANDOM_10375617',
        TEST_COUNTER_CURRENCY,
        TEST_LOCAL_STORE_ABS_PATH_NO_DATA,
      )
    end
    assert_raises(Exception) do
      bad_remote_source.get
    end
  end


  def test_load_succeeds_on_good_local_file
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_COUNTER_CURRENCY,
      TEST_LOCAL_STORE_ABS_PATH_GOOD_DATA
    )
    data_hash = source.load_from_store
    refute_empty data_hash
  end


  def test_load_fails_with_empty_local_data_raises_local_source_error
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_COUNTER_CURRENCY,
      TEST_LOCAL_STORE_ABS_PATH_NO_DATA
    )
    assert_raises(LocalSourceError) do
      source.load_from_store
    end
  end


  def test_save_feed_data_with_nonexistant_store_creates_one
    source = suppress_output do
      ExchangeRateHistory::Source.new(
        TEST_SOURCE_URL,
        TEST_COUNTER_CURRENCY,
        TEST_TEMP_FILE
      )
    end
    source.update_store({"test" => "hash"})
    assert_equal true, source.local_file_flag
    pn = Pathname.new(source.local_store_abs_path)
    assert_equal true, pn.exist?
    `rm #{TEST_TEMP_FILE}`
  end


  def test_save_feed_data_with_populated_store_same_data
    # create temp file
    File.open(TEST_TEMP_FILE, "w") do |f|
      f << {"test" => "hash"}.to_json
    end

    # init object
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_COUNTER_CURRENCY,
      TEST_TEMP_FILE
    )

    # update with same data
    source.update_store({"test" => "hash"})

    # assert no change
    file_contents = ""
    File.open(TEST_TEMP_FILE, "r") do |f|
      assert f.read == {"test" => "hash"}.to_json
    end

    # clean up
    `rm #{TEST_TEMP_FILE}`
  end

    
  def test_save_feed_data_with_populated_store_add_data
    # create temp file
    File.open(TEST_TEMP_FILE, "w") do |f|
      f << {"test" => "hash"}.to_json
    end

    # init object
    source = ExchangeRateHistory::Source.new(
      TEST_SOURCE_URL,
      TEST_COUNTER_CURRENCY,
      TEST_TEMP_FILE
    )

    # update with new data
    source.update_store({"second" => "hashhh"})

    # assert changes
    file_contents = ""
    File.open(TEST_TEMP_FILE, "r") do |f|
      assert f.read == {"test" => "hash", "second" => "hashhh"}.to_json
    end

    # clean up
    `rm #{TEST_TEMP_FILE}`
  end


  def test_init_no_sources_raises_error
    assert_raises(RuntimeError) do
      source = suppress_output do
        ExchangeRateHistory::Source.new(
        "https://this/doesnt/exist/file.RANDOM_10375617",
        TEST_COUNTER_CURRENCY,
        'no-such.file'
      )
      end
    end
  end


  def test_get_rate_at_all_paths
    source =  suppress_output do
      ExchangeRateHistory::Source.new(
        "https://this/doesnt/exist/file.RANDOM_10375617",
        TEST_COUNTER_CURRENCY,
        TEST_LOCAL_STORE_ABS_PATH_GOOD_DATA
      )
    end

    suppress_output do
      source.update_cache
    end

    assert_equal "1.00", source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'EUR')

    assert_equal "1.00", source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'USD', 'USD')

    source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'USD')
    source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'JPY')
    source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'JPY', 'EUR')
    source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'EUR', 'JPY')
    source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'JPY', 'USD')

    assert_raises(KeyError) do
      source.get_rate_at(Date.today, 'USD')
    end

    assert_raises(KeyError) do
      source.get_rate_at(Date.parse("1900-01-01"), 'USD')
    end

    assert_raises(KeyError) do
      source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'XXX')
    end
    
    assert_raises(KeyError) do
      source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'USD', 'XXX')
    end

    assert_raises(KeyError) do
      source.get_rate_at(TEST_DATE_IN_SOURCE_JSON, 'XXX', 'USD')
    end

  end

end