module Webber
  class Connection < EventMachine::Connection

    attr_accessor :server
    attr_accessor :request
    attr_accessor :response

    # EM 初始化请求
    def post_init
      @request  = ::Thin::Request.new
      @response = ::Thin::Response.new
    end

    # EM 接收 data
    def receive_data(data)
      EM.defer do  
        # thin -> 解析 http
        @request.parse(data)

        # 获取 env
        env = @request.env

        # 默认 middlewave 先被执行
        app = AppExecutor.method(:run)
        # 代码重新加载
        app = Reloader.new(app,Engine.server.logger) if @server.code_reload
        # rack -> 代码异常
        app = Rack::ShowExceptions.new(app)
        # rack -> 请求日志
        app = Rack::CommonLogger.new(app,Engine.server.logger)
        # rack -> 自动分配 Content-Encoding
        app = Rack::Deflater.new(app)
        # 计算 content-length
        app = ContentLength.new(app)

        @response.status, @response.headers, @response.body = app.call(env)
        @response.each do |chunk|
          send_data chunk
        end
      end
    end

    def unbind
      @server.connection_finished(self)
    end
  end
end

