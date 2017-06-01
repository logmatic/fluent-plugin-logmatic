require 'net/http'
require 'net/https'
require 'uri'
require 'yajl'

class Fluent::LogmaticOutput < Fluent::BufferedOutput
  class ConnectionFailure < StandardError;
  end

  # Register the plugin
  Fluent::Plugin.register_output('logmatic_http', self)

  # Output settings
  config_param :use_json, :bool, :default => true
  config_param :include_tag_key, :bool, :default => false
  config_param :tag_key, :string, :default => 'tag'

  # API Settings
  config_param :api_key, :string

  #  Connection settings
  config_param :max_retries, :integer, :default => -1
  config_param :endpoint, :string, :default => "https://api.logmatic.io/v1/input/"


  def initialize
    super
  end

  def configure(conf)
    super(conf)
    # Http client
    @uri = URI.parse(@endpoint + @api_key)
    @https = Net::HTTP.new(@uri.host, @uri.port)
    @https.use_ssl = true
    log.trace("Setting new connection to https://#{@uri.host}:#{@uri.port}")
  end

  def start
    super
  end

  def shutdown
    super
  end


  # This method is called when an event reaches Fluentd.
  def format(tag, time, record)
    return [tag, record].to_msgpack
  end

  # NOTE! This method is called by internal thread, not Fluentd's main thread.
  # 'chunk' is a buffer chunk that includes multiple formatted events.
  def write(chunk)

    messages = Array.new

    # Pack messages
    chunk.msgpack_each do |tag, record|

      log.trace("New chunk received: #{record}, #{tag}")
      next unless record.is_a? Hash
      next unless record.has_key? "message"


      if @include_tag_key
        record[@tag_key] = tag
      end

      log.trace("Json message: #{Yajl.dump(record)}")
      messages.push Yajl.dump(record)
    end

    # Send them
    log.trace("Sending #{messages.length} messages")
    retries = 0
    force_retry = false

    if (messages.length > 0)

      log.trace("Full message body: #{Yajl.dump(messages)}")
      begin

        force_retry = false
        req = Net::HTTP::Post.new(@uri.path)
        req['Content-Type'] = 'application/json'
        req.body = Yajl.dump(messages)
        log.trace("Posting data")
        res = @https.request(req)
        log.trace("Status code: #{res.code}")

        if (res.code.to_i != 0 && res.code.to_i != 200)
          if retries < @max_retries || max_retries == -1

            a_couple_of_seconds = retries ** 2
            a_couple_of_seconds = 30 unless a_couple_of_seconds < 30
            retries += 1
            log.warn "Could not push logs to Logmatic, attempt=#{retries} max_attempts=#{max_retries} wait=#{a_couple_of_seconds}s error=#{res.code}"

            sleep a_couple_of_seconds
            force_retry = true
            raise "Status code: #{res.code}"

          end
        end
      rescue => e
        # Handle some failures
        log.error("Error while sending data. Making a new attempt. Error: #{e}")
        retry if force_retry
        raise ConnectionFailure, "Could not push logs to Logmatic after #{retries} retries, #{e.message}"
      end
    end
  end

end
