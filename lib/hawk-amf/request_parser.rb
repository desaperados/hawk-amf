module HawkAMF
  class RequestParser
    def initialize app, config={}, logger=nil
      @app = app
      @config = config
      @logger = logger || Logger.new(STDERR)
    end

    # If the content type is AMF and the path matches the configured gateway path,
    # it parses the request, creates a response object, and forwards the call
    # to the next middleware. If the amf response is constructed, then it serializes
    # the response and returns it as the response.
    def call env
      return @app.call(env) unless should_handle?(env)

      # Wrap request and response
      env['rack.input'].rewind
      
      # Catch any errors thrown during RocketAMF Envelope construction
      begin
        env['hawkamf.request'] = RocketAMF::Envelope.new.populate_from_stream(env['rack.input'].read)
      rescue Exception => e
        handle_serialization_failure(e)
      end
      
      env['hawkamf.response'] = RocketAMF::Envelope.new
      
      # Pass up the chain to the request processor, or whatever is layered in between
      result = @app.call(env)

      # Calculate length and return response
      if env['hawkamf.response'].constructed?
        @logger.info "Sending back AMF"
        response = env['hawkamf.response'].to_s
        return [200, {"Content-Type" => Mime::AMF.to_s, 'Content-Length' => response.length.to_s}, [response]]
      else
        return result
      end
    end
    
    def handle_serialization_failure(exception)
      @logger.error exception
      response = exception.message.to_s
      return [400, {"Content-Type" => "text/plain", 'Content-Length' => response.length.to_s}, [response]]
    end

    # Check if we should handle it based on the environment
    def should_handle? env
      return false unless env['CONTENT_TYPE'] == Mime::AMF
      return false unless [*@config.gateway_path].include?(env['PATH_INFO'])
      true
    end
  end
end