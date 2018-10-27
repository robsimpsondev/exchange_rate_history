require 'minitest/autorun'
require 'exchange_rate_history/source'

class SourceTest < Minitest::Test

  def setup
    # set up source for testing
    abs_local_file_path = File.dirname(__FILE__) + '/source_fixtures/test_data.xml'
    @source = ExchangeRateHistory::Source.new(
      abs_local_file_path: abs_local_file_path,
    )
  end

  def teardown
    # nothing
  end

  def test_check_local_true_for_existing_file
    assert @source.check_local
  end

  def test_check_local_raises_for_nonexistant_file
    bad_local_source = ExchangeRateHistory::Source.new(abs_local_file_path: 'a/file/that/doesnt_exist/anywhere_at.all')
    assert_raises(LocalSourceNotFoundError) do
      bad_local_source.check_local
    end
  end

  def test_check_local_file_not_found_checks_remote
  end

  def test_check_remote_success_returns_true
  end

  def test_check_remote_fails_causes_remote_source_error
  end

  def test_get_succeeds_with_good_remote_is_sucessful
  end

  def test_get_fails_returns_remote_source_error
  end

  def test_update_from_zero_data
  end

  def test_update_with_bad_data_raises_remote_source_error
  end

  def test_rate_parser_succeeds_on_local_file
  end

  def test_rate_parser_fails_with_bad_data_raises_remote_source_error
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