require 'pathname'
require 'resolv'
require 'net/http'
require 'open-uri'
require 'json'

require 'exchange_rate_history'


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


class LocalSourceError < SourceError
end


class LocalSourceNotFoundError < LocalSourceError
end


class RemoteSourceError < SourceError
end


class InternetConnectionError < RuntimeError
end


class ExchangeRateHistory::Source

  attr_reader :source_url, :local_store_abs_path, :base_currency, :local_file_flag, :remote_file_flag, :response, :cache

  def initialize(source_url, base_currency,  local_store_abs_path = nil)

    @source_url = source_url
    @base_currency = base_currency
    @cache = {}  # cache is a hash object, all external access to source data is through the cache

    # Set the default store name in working directory
    unless local_store_abs_path
      @local_store_abs_path = Dir.pwd + "/" + "exchange_rate_data.json"
    else
      @local_store_abs_path = local_store_abs_path
    end

    @local_file_flag = nil    # to be determined T/F
    @remote_file_flag = nil   # to be determined T/F
    check_file_status         # sets the above flags
  end


  def check_local
    pn = Pathname.new(@local_store_abs_path)
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


  def check_file_status
    # There may not be a local file.
    # and that is OK.
    begin
      check_local
    rescue LocalSourceNotFoundError => ex
      $stderr.puts "Local data file not found."
    end

    # We may not be able to reach to remote source.
    # This is only Ok if we have a local file.
    begin
      check_remote
    rescue RemoteSourceError => ex
      $stderr.puts "Remote source could not be reached."
      unless @local_file_flag
        raise "Neither local nor remote data could be accessed"
      end
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


  def load_cache_from_store(store_file = @local_store_abs_path)
    file_string_size = nil
    begin
      File.open(store_file, "r") do |f|
        file_str = f.read
        file_string_size = file_str.size
        @cache.merge!(JSON.parse(file_str).to_hash)
      end
    rescue JSON::ParserError => ex
      if file_string_size == 0
        raise LocalSourceError, "Local file is empty: #{ex}"
      else
        raise LocalSourceError, "#{ex}"
      end
    end
  end


  def update_store
  end


  def update_cache
    # Get the most up to date data that is reachable
    if remote_file_flag
      get
      update_store
      load_cache_from_store
    else
      load_cahe_from_store
    end
  end
  
end