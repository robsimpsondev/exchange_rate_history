require 'exchange_rate_history'
require 'pathname'


# TODO: Factor out into default source class
DEFAULT_SOURCE = 'www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
DEFAULT_LOCAL_PATH = File.dirname(__FILE__) + 'DEFAULT_SOURCE.xml'


class SourceError < RuntimeError
end

class LocalSourceNotFoundError < SourceError
end


class ExchangeRateHistory::Source
  def initialize(
    source_uri: DEFAULT_SOURCE,
    abs_local_file_path: DEFAULT_LOCAL_PATH,
    base_currency: 'EUR')

    @source_uri = source_uri
    @abs_local_file_path = abs_local_file_path
    @base_currency = base_currency

    @local_file = nil  # to be determined T/F
    @remote_file = nil

    # First check for a local file
    # If it doesn't exist look for a remote
    begin
      if check_local
        @local_file = true
      end
    rescue LocalSourceNotFoundError => ex
      @local_file = false
      if check_remote
        @remote_file = true
      end
    end

  end

  def check_local
    pn = Pathname.new(@abs_local_file_path)
    if pn.exist?
      return true
    else
      raise LocalSourceNotFoundError, "local file not found during Source initialization"
    end
  end

  def check_remote
    true
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