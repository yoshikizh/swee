# -*- encoding: utf-8 -*-
module Swee

  class ContentLength
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers.merge!( { "Content-Length" => calc_length(body) } )
      [status, headers, body]
    end

    private
    def calc_length(body)
      length = 0
      body.each { |part| length += part.bytesize }
      length
    end
  end
end
