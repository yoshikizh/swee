module Swee
  class Config
    class BaseConfig
      def absolutely_app_path _file
        _file.start_with?("/") ? _file : File.expand_path(_file,ENV["app_path"])
      end

      def [](key)
        send(key)
      end
    end

    class ServerConfig < BaseConfig
      attr_accessor :listen
      attr_accessor :handle_request_mode
      attr_accessor :env
      attr_accessor :logger_level
      attr_accessor :code_reload
      attr_accessor :restart_mode
      attr_accessor :touch_file
      attr_accessor :pid_file
      attr_accessor :log_file
      attr_accessor :max_connections
      attr_accessor :performance_monitoring
      attr_accessor :run_background
      attr_accessor :cmd

      def default_config! options
        @listen = ( options[:listen] || 3000 )
        @handle_request_mode  ||= :event_loop
        @env = ( options[:env] || :development )
        @logger_level ||= :debug
        @code_reload ||= true
        @restart_mode ||= :pid
        @touch_file ||= File.expand_path("./tmp/restart.txt",ENV["app_path"])
        @pid_file ||= File.expand_path("./tmp/pid",ENV["app_path"])
        @log_file ||= [ File.expand_path("./logs/#{env.to_s}.log",ENV["app_path"]), 10, 10240000 ]
        @max_connections ||= 1024
        @performance_monitoring ||= false
        @run_background ||= false
        @cmd = options[:cmd]
      end

      # def touch_file=(_file)
      #   @touch_file = absolutely_app_path(_file)
      # end

      # def pid_file=(_file)
      #   @touch_file = absolutely_app_path(_file)
      # end

    end

    class AppConfig < BaseConfig
      attr_accessor :time_zone
      attr_accessor :default_locale
      attr_accessor :page404
      attr_accessor :page500
      attr_accessor :include_path
      attr_accessor :email

      # def page404=(_file)
      #   @page404 = absolutely_app_path(_file)
      # end

      # def page500=(_file)
      #   @page500 = absolutely_app_path(_file)
      # end

      def default_config! options
        @time_zone      ||=  "Beijing"
        @default_locale ||=  "zh-CN"
        @page404        ||=  File.expand_path("./public/404.html",ENV["app_path"])
        @page500        ||=  File.expand_path("./public/500.html",ENV["app_path"])
        @include_path   ||=  []
        @email          ||=  {}
      end
    end

    { ServerConfig => [ :pid_file=, :touch_file=], AppConfig => [:page404=, :page500=] }.each do |_kls, _methods|
      _methods.each do |_m|
        _kls.send(:define_method,_m) do |_file|
          eval "@#{_m.to_s} absolutely_app_path('#{_file}')"
        end
      end
    end

    class DbConfig < BaseConfig
      attr_accessor :adapter
      attr_accessor :database
      attr_accessor :host
      attr_accessor :username
      attr_accessor :password
      attr_accessor :encoding
      attr_accessor :pool

      def default_config! options

      end
    end

    class AppPluginConfig

    end

    attr_accessor :app, :server, :db, :app_plugin
    def initialize
      @server = ServerConfig.new
      @app    = AppConfig.new
      @db     = DbConfig.new
      # @plugin = AppPluginConfig.new
    end

    def default_config! options
      [@server,@app,@db].each { |cfg| cfg.default_config! options }
    end
  end
end