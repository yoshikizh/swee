
    # attr_accessor :config
    # def initialize
    #   @port,@env = ENV["start_port"], ENV["app_env"]
    #   @config = Webber::Application.config
    #   @middlewares = []
    # end

    # def use(middleware_class,*options, &block)
    #   @middlewares << lambda {|app| middleware_class.new(app,*options, &block)}
    # end

    # def use_lambda _lambda
    #   @middlewares << _lambda
    # end

    # def run(app)
    #   @app = app
    # end

    # def to_app
    #   @middlewares.reverse.inject(@app) { |app, middleware| middleware.call(app)}
    # end

    # def load_default_middlewares
    #   use Rack::ContentLength
    #   # use Rack::ContentType,"text/plain"
    #   use Rack::CommonLogger, $stder   # => 记录日志

    #   use Rack::Chunked                # => 分块传输 (很多服务器自动use了该中间件)

    #   use Rack::ConditionalGet         # => get资源缓存控制
    #   # use Rack::Etag                   # => 判断计算url对象是否改变 和 ConditionalGet 中间件一起使用
    #   use Rack::Deflater               # => http 传输内容编码(压缩)

    #   # use Rack::Head                 # => RFC2616要求HEAD请求的响应体必须为空这就是Rack::HEAD所做的事情

    #   use Rack::MethodOverride         # => 用 post 模拟 put 和 delete
    #                                    # => 需要表单中加入了一个隐含字段“_method” 把它的值设为“put 或 delete“
    #   # use Rack::Lint                 # => 检查请求和响应是否符合Rack规格

    #   use Rack::Reloader, 2            # => 开发环境用 修改代码不重启服务器
    #   # use Rack::Runtime              # => header中加入一个 请求的处理时间 X-Runtime

    #   # use Rack::Sendfile               # => 传送文件

    #   # apps = [lambda {|env| [404, {}, ["File doesn't exists"]]}, lambda {|env| [200, {}, ["I'm ok"]]}]
    #   # use Rack::Cascade                # => 挂载多个应用程序 它会尝试所有这些应用程序，直到某一个应用程序返回的代码不是404

    #   # use Rack::Lock                   # => 不支持多线程框架 将互锁 

    #   # use Rack::Session::Cookie, :key => 'rack.session',       # => key, 缺省为 rack.session
    #   #                            :domain => 'example.com',     # => 域名
    #   #                            :path => '/',                 # => 路径
    #   #                            :expire_after => 2592000,     # => 过期时间
    #   #                            :secret => 'any_secret_key'   # => cookie 加密
      
    #   # default_options = {
    #   #   :path => '/',
    #   #   :domain => nil,
    #   #   :expire_after => nil,
    #   #   :secure => false,
    #   #   :httponly => true,
    #   #   :defer => false,       # => 如果设置defer为true,那么响应头中将不会设置cookie(暂时还不知道有什么用处)
    #   #   :renew => false,       # => 如果设置此选项为true,那么在具体的会话管理实现中不应该把原先客户端通过请求发送的session_id,
    #   #                          # => 而是每次生成一个新的session_id,并把原先session_id对应的会话数据和这个新的session_id对应。
    #   #                          # 注意renew的优先级高于defer,也就是即使defer设置为true,
    #   #                          # 只要设置了renew为true,那么cookie也会被写入到响应头中
    #   #   :sidbits => 128        # => 生成的session_id长度为多少个bit, ID类提供了一个实用的generate_sid方法可以供你的具体实现使用
    #   # }
    #   # use Rack::Session::Abstract::ID,default_options

    #   # default_options = Rack::Session::Abstract::ID::DEFAULT_OPTIONS.merge ({ 
    #   #   :namespace => 'rack:session', :memcache_server => 'localhost:11211'
    #   # })
    #   # use Rack::Session::Memcache, DEFAULT_OPTIONS
    # end