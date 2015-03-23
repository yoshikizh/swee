# -*- encoding: utf-8 -*-
module Thin

  module VERSION #:nodoc:
    MAJOR    = 1
    MINOR    = 6
    TINY     = 3
    
    STRING   = [MAJOR, MINOR, TINY].join('.')
    
    CODENAME = "Protein Powder".freeze
    
    RACK     = [1, 0].freeze # Rack protocol version
  end

  NAME    = 'thin'.freeze
  SERVER  = "#{NAME} #{VERSION::STRING} codename #{VERSION::CODENAME}".freeze  

  HTTP_STATUS_CODES = {  
    100  => 'Continue', 
    101  => 'Switching Protocols', 
    200  => 'OK', 
    201  => 'Created', 
    202  => 'Accepted', 
    203  => 'Non-Authoritative Information', 
    204  => 'No Content', 
    205  => 'Reset Content', 
    206  => 'Partial Content', 
    300  => 'Multiple Choices', 
    301  => 'Moved Permanently', 
    302  => 'Moved Temporarily', 
    303  => 'See Other', 
    304  => 'Not Modified', 
    305  => 'Use Proxy', 
    400  => 'Bad Request', 
    401  => 'Unauthorized', 
    402  => 'Payment Required', 
    403  => 'Forbidden', 
    404  => 'Not Found', 
    405  => 'Method Not Allowed', 
    406  => 'Not Acceptable', 
    407  => 'Proxy Authentication Required', 
    408  => 'Request Time-out', 
    409  => 'Conflict', 
    410  => 'Gone', 
    411  => 'Length Required', 
    412  => 'Precondition Failed', 
    413  => 'Request Entity Too Large', 
    414  => 'Request-URI Too Large', 
    415  => 'Unsupported Media Type',
    422  => 'Unprocessable Entity',   
    500  => 'Internal Server Error', 
    501  => 'Not Implemented', 
    502  => 'Bad Gateway', 
    503  => 'Service Unavailable', 
    504  => 'Gateway Time-out', 
    505  => 'HTTP Version not supported'
  }

  # A response sent to the client.
  class Response
    CONNECTION     = 'Connection'.freeze
    CLOSE          = 'close'.freeze
    KEEP_ALIVE     = 'keep-alive'.freeze
    SERVER         = 'Server'.freeze
    CONTENT_LENGTH = 'Content-Length'.freeze

    PERSISTENT_STATUSES  = [100, 101].freeze

    #Error Responses
    ERROR            = [500, {'Content-Type' => 'text/plain'}, ['Internal server error']].freeze
    PERSISTENT_ERROR = [500, {'Content-Type' => 'text/plain', 'Connection' => 'keep-alive', 'Content-Length' => "21"}, ['Internal server error']].freeze
    BAD_REQUEST      = [400, {'Content-Type' => 'text/plain'}, ['Bad Request']].freeze

    # Status code
    attr_accessor :status

    # Response body, must respond to +each+.
    attr_accessor :body

    # Headers key-value hash
    attr_reader   :headers

    def initialize
      @headers    = Headers.new
      @status     = 200
      @persistent = false
      @skip_body  = false
    end

    # String representation of the headers
    # to be sent in the response.
    def headers_output
      # Set default headers
      @headers[CONNECTION] = persistent? ? KEEP_ALIVE : CLOSE unless @headers.has_key?(CONNECTION)
      @headers[SERVER]     = Thin::NAME unless @headers.has_key?(SERVER)

      @headers.to_s
    end

    # Top header of the response,
    # containing the status code and response headers.
    def head
      "HTTP/1.1 #{@status} #{HTTP_STATUS_CODES[@status.to_i]}\r\n#{headers_output}\r\n"
    end

    # if Thin.ruby_18?

    #   # Ruby 1.8 implementation.
    #   # Respects Rack specs.
    #   #
    #   # See http://rack.rubyforge.org/doc/files/SPEC.html
    #   def headers=(key_value_pairs)
    #     key_value_pairs.each do |k, vs|
    #       vs.each { |v| @headers[k] = v.chomp } if vs
    #     end if key_value_pairs
    #   end

    # else

      # Ruby 1.9 doesn't have a String#each anymore.
      # Rack spec doesn't take care of that yet, for now we just use
      # +each+ but fallback to +each_line+ on strings.
      # I wish we could remove that condition.
      # To be reviewed when a new Rack spec comes out.
      def headers=(key_value_pairs)
        key_value_pairs.each do |k, vs|
          next unless vs
          if vs.is_a?(Integer)
            vs = vs.to_s
          end
          if vs.is_a?(String)
            vs.each_line { |v| @headers[k] = v.chomp }
          else
            vs.each { |v| @headers[k] = v.chomp }
          end
        end if key_value_pairs
      end

    # end

    # Close any resource used by the response
    def close
      @body.close if @body.respond_to?(:close)
    end

    # Yields each chunk of the response.
    # To control the size of each chunk
    # define your own +each+ method on +body+.
    def each
      yield head

      unless @skip_body
        if @body.is_a?(String)
          yield @body
        else
          @body.each { |chunk| yield chunk }
        end
      end
    end

    # Tell the client the connection should stay open
    def persistent!
      @persistent = true
    end

    # Persistent connection must be requested as keep-alive
    # from the server and have a Content-Length, or the response
    # status must require that the connection remain open.
    def persistent?
      (@persistent && @headers.has_key?(CONTENT_LENGTH)) || PERSISTENT_STATUSES.include?(@status)
    end

    def skip_body!
      @skip_body = true
    end
  end
end
