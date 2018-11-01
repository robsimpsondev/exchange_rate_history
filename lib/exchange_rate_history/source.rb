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

  attr_reader :source_url, :local_store_abs_path, :source_counter_currency, :local_file_flag, :remote_file_flag, :response, :cache

  def initialize(source_url, source_counter_currency,  local_store_abs_path = nil)

    @source_url = source_url
    @source_counter_currency = source_counter_currency
    @cache = {}  # cache is a hash object, all external access to source data is through the cache

    # Set the default store name in working directory
    unless local_store_abs_path
      @local_store_abs_path = Dir.pwd + "/" + "exchange_rate_data.json"
    else
      @local_store_abs_path = local_store_abs_path
    end

    @local_file_flag = nil    # to be determined T/F
    @remote_file_flag = nil   # to be determined T/F
    update_file_status         # sets the above flags
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


  def update_file_status
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
      return response
    else
      raise "get called for Source with bad remote"
    end
  end


  def source_rate_parser(source_response = @response)
    raise NotImplementedError, "Sources must have a :source_rate_parser method defined"
    # see:
    #  - README.md
    # or:
    #  - https://github.com/robsimpsondev/exchange_rate_history/blob/master/README.md
    # or, for an example:
    #  - ./sources/ECB90Day.rb
    #
    # This method should end with:
    # return source_data_hash
  end


  def load_from_store(store_file = @local_store_abs_path)
    file_string_size = nil
    data_hash = {}
    begin
      File.open(store_file, "r") do |f|
        file_str = f.read
        file_string_size = file_str.size
        data_hash.merge!(JSON.parse(file_str).to_hash)
      end
    rescue JSON::ParserError => ex
      if file_string_size == 0
        raise LocalSourceError, "Local file is empty: #{ex}"
      else
        raise LocalSourceError, "#{ex}"
      end
    end
    return data_hash
  end


  def update_store(source_data_hash)
    if @local_file_flag
      existing_data = load_from_store
      existing_data.merge!(source_data_hash)
      File.open(@local_store_abs_path, "w") do |f|
        f << existing_data.to_json
      end
    else
      # Create a new store
      File.open(@local_store_abs_path, "w") do |f|
        f << source_data_hash.to_json
      end
    end
    # update the file flags again since we may have created a local store
    update_file_status
  end


  def update_cache
    # Get the most up to date data that is reachable
    update_file_status
    if remote_file_flag
      response = get
      # :source_rate_parser must be implemented in child class
      update_store(source_rate_parser(response))
      @cache = load_from_store
    else
      @cache = load_from_store
    end
  end


  def get_rate_at(time_str, to_currency, from_currency = @source_counter_currency)
    # N.B: since an exchange would never offer the inverse
    # of their selling price as their buying price then
    # calculating any rate where from_currency
    # is not the source_counter_currency should really be forbidden,
    # unless we are dealing with reference rates.
    if to_currency == from_currency
      return "1.00"
    elsif from_currency == @source_counter_currency
      return @cache.fetch(time_str.iso8601).fetch(to_currency)
    elsif to_currency == @source_counter_currency
      value_of_from = 1.0/@cache.fetch(time_str.iso8601).fetch(from_currency).to_f
      return value_of_from.to_s
    else
      value_of_from = 1.0/@cache.fetch(time_str.iso8601).fetch(from_currency).to_f
      pair_rate = value_of_from * @cache.fetch(time_str.iso8601).fetch(to_currency).to_f
      return pair_rate.to_s
    end
  end
end