# -*- encoding: utf-8 -*-
module Rack
  class CommonLogger
    def initialize(app, logger=nil)
      @app = app
      @logger = logger
    end

    private

    def log(env, status, header, began_at)
      now = Time.now
      length = extract_content_length(header)

      msg = FORMAT % [
        env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        env["REMOTE_USER"] || "-",
        now.strftime("%d/%b/%Y:%H:%M:%S %z"),
        env['REQUEST_METHOD'],
        env['PATH_INFO'],
        env['QUERY_STRING'].empty? ? "" : "?"+env['QUERY_STRING'],
        env["SERVER_PROTOCOL"],
        status.to_s[0..3],
        length,
        now - began_at ]

      @logger << msg
    end
  end
end
