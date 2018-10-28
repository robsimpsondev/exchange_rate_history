require 'pathname'
require 'resolv'
require 'net/http'
require 'open-uri'

require 'exchange_rate_history'


# TODO: Factor out into default source class
DEFAULT_SOURCE = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
DEFAULT_LOCAL_PATH = File.dirname(__FILE__) + 'DEFAULT_SOURCE.xml'


def internet_connection?
  dns_resolver = Resolv::DNS.new()
  begin
    dns_resolver.getaddress("symbolics.com")  # First ever registered domain name
  rescue Resolv::ResolvError => e
    return false
  end
  return true
end


def remote_file_available?(url)
  url = URI.parse(url)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = (url.scheme == "https")
  http.start do |http|
    return http.head(url.request_uri).code == "200"
  end
end


class SourceError < RuntimeError
end


class LocalSourceNotFoundError < SourceError
end


class RemoteSourceError < SourceError
end


class InternetConnectionError < RuntimeError
end


class ExchangeRateHistory::Source

  attr_reader :source_url, :abs_local_file_path, :base_cuurency, :local_file_flag, :remote_file_flag, :response

  def initialize(
    source_url: DEFAULT_SOURCE,
    abs_local_file_path: DEFAULT_LOCAL_PATH,
    base_currency: 'EUR')

    @source_url = source_url
    @abs_local_file_path = abs_local_file_path
    @base_currency = base_currency

    @local_file_flag = nil  # to be determined T/F
    @remote_file_flag = nil  # to be determined T/F

    # There may not be a local file yet
    # and that is OK.
    begin
      check_local
    rescue LocalSourceNotFoundError => ex
      puts "Data file not found during initialiazation"
    end

    # We may not be able to reach to remote source.
    # This is only Ok if we have a local file.
    begin
      check_remote
    rescue RemoteSourceError => ex
      $stderr.puts "Remote source could not be reached during initialization"
      unless @local_file_flag
        raise "Neither local nor remote data could be accessed"
      end
    end

  end

  def check_local
    pn = Pathname.new(@abs_local_file_path)
    if pn.exist?
      @local_file_flag = true
      return true
    else
      @local_file_flag = false
      raise LocalSourceNotFoundError, "local data file not found"
    end
  end

  def check_remote
    raise InternetConnectionError unless internet_connection?
    begin
      if remote_file_available?(@source_url)
        @remote_file_flag = true
        return true
      else
        @remote_file_flag = false
        raise RemoteSourceError, "Remote source response failed (was not 200)"
      end
    rescue SocketError => ex
      raise RemoteSourceError, "#{ex}"
    end
  end

  def get
    if @remote_file_flag
      url = URI.parse(@source_url)
      @response = Net::HTTP.get_response(url)
    else
      raise "get called for Source with bad remote"
    end
  end

  def source_rate_parser()
    raise NotImplementedError, "Sources must have a :source_rate_parser method defined"
    # see:
    #  - README.md
    # or:
    #  - https://github.com/robsimpsondev/exchange_rate_history/blob/master/README.md
    # or, for an example:
    #  - ./sources/ECB90Day.rb
  end
  
end