require 'socket'
require 'yaml'
require 'openssl'

class Fluent::LogmaticOutput < Fluent::BufferedOutput
  class ConnectionFailure < StandardError; end

  # Register the plugin
  Fluent::Plugin.register_output('logmatic', self)

  # Output settings
  config_param :use_json,       :bool,    :default => true

  # Connection settings
  config_param :host,           :string,    :default => 'api.logmatic.io'
  config_param :use_ssl,        :bool,    :default => true
  config_param :port,           :integer, :default => 10514
  config_param :ssl_port,       :integer, :default => 10515
  config_param :max_retries,    :integer, :default => 3
  
  # API Settings
  config_param :api_key,  :string

  
  def configure(conf)
    super
    @last_edit = Time.at(0)
  end

  def start
    super
  end

  def shutdown
    super
  end

  def client

   @_socket ||= if @use_ssl
      context    = OpenSSL::SSL::SSLContext.new
      socket     = TCPSocket.new @host, @ssl_port
      ssl_client = OpenSSL::SSL::SSLSocket.new socket, context
      ssl_client.connect
    else
      TCPSocket.new @host, @port
    end

  end

  # This method is called when an event reaches Fluentd.
  def format(tag, time, record)
    return [tag, record].to_msgpack
  end

  # NOTE! This method is called by internal thread, not Fluentd's main thread.
  # 'chunk' is a buffer chunk that includes multiple formatted events.
  def write(chunk)
    
    chunk.msgpack_each do |tag, record|
      next unless record.is_a? Hash
      next unless @use_json or record.has_key? "message"
      message = @use_json ? record.to_json : record["message"].rstrip()
      send_to_logmatic(message)
    end

  end

  def send_to_logmatic(data)

    retries = 0

    begin

      client.write("#{api_key} #{data}\n")

    # Handle some failures
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::EPIPE => e

      if retries < @max_retries
        retries += 1
        @_socket = nil
        log.warn "Could not push logs to Logmatic API, resetting connection and trying again. #{e.message}"
        a_couple_of_seconds = 5**retries 
        sleep a_couple_of_seconds
        retry
      end
      raise ConnectionFailure, "Could not push logs to Logmatic, attempt=#{retries} max_attempts=#{max_retries} wait=#{a_couple_of_seconds}s error=#{e.message}"
    end
  end

end
