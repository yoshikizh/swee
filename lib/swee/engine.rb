require 'optparse'
require 'erb'
require 'rack'
require 'eventmachine'
# require 'socket'

#File.expand_path('../../../../', __FILE__)
ENV["app_path"] = Dir.pwd

module Swee
  # 获取 app 路径
  def root
    ENV["app_path"]
  end

  # 获取app配置
  def app_config
    yield self.config.app
  end

  # 获取 服务器配置
  def server_config
    yield self.config.server
  end

  # 获取 数据库配置
  def database_config

  end

  # 配置实例
  def config
    @@config
  end

  # 初始化
  def init_config
    @@config = Config.new
  end

  # 静态化
  module_function :root,:app_config,:server_config,:config, :database_config, :init_config

  class Engine
    @@__instance__ = nil     # => 实例
    @@__server__   = nil     # => 服务器

    def initialize options
      # 初始化配置
      @config = Swee.init_config

      # 读取用户配置
      require_user_appconfig

      # 合并配置
      merge_config! options
    end

    # 加载 app配置
    def require_user_appconfig
      # require_relative './application'
      Lodder.app_require
    end

    # 合并配置
    def merge_config! options
      @config.default_config! options
    end

    class << self
      # 当前实例
      def instance
        @@__instance__
      end
      # 配置实例
      def config
        instance.send :config
      end
      # 服务器实例
      def server
        @@__server__
      end

      # def load_middlewares
      #   @@instance.load_default_middlewares
      # end

      # def parse_path_info
      #   @@instance.run method(:path_to_routes)
      # end

      # 命令行解析
      def parse_options
        options = {}
        OptionParser.new do |opts|
          opts.banner = "swee框架使用参数如下"

          opts.on("-p", "--port PORT", Integer,
                  "端口 (默认: 3000)") do |port|
            options[:listen] = port
          end

          opts.on("-e", "--env ENV",
                  "环境 development 或 production (默认为development)") do |e|
            options[:env] = e
          end
        end.parse!
        options
      end

      # 启动服务
      def boot! argv
        cmd = argv.shift || "s"
        options = parse_options.merge({:cmd => cmd})

        case cmd
        when "new"
          proj_name = argv.shift
          if proj_name.nil?
            puts "格式错误,请输入: swee new 项目名称"
            return
          end
          require_relative './installer'
          Installer.run(proj_name)
          return
        when "g"  # => Todo: generation 生成
          return
        else
          require_files
          cache_file_mtime
          @@__instance__ = self.new options
          parse_cmd cmd,options
        end
      end

      # 解析命令
      # c -> 命令行
      # s -> 启动服务
      def parse_cmd cmd,options
        case cmd
        when "c"   # => 命令行模式
          require 'irb'
          IRB.start
        when "s"   # => 启动服务器
          start_server!
        else
          raise "命令不合法"
        end
      end

      # 加载全部文件
      def require_files
        # require 加载器 Lodder
        require_relative './lodder'
        Lodder.all

        _app_path = ENV["app_path"]

        # _app_env = Application.config["app_env"]

        # if (begin
        #       require "active_record"
        #     rescue
        #       false
        #     end)
        #   ActiveRecord::Base.establish_connection YAML::load(File.open(ENV["app_path"]+'/database.yml'))[_app_env]
        # end

        # 加载路由
        require File.expand_path('./routes', _app_path)

        # 加载控制器
        Dir.glob("#{_app_path}/controllers/*.rb") { |f| require  f }

        # 加载模型
        Dir.glob("#{_app_path}/models/*.rb") { |f| require  ENV["app_path"] + "/models/"+File.basename(f, '.*') }

      end

      def cache_file_mtime
        Lodder.cache_file_mtime
      end

      # 重启服务器
      def restart_server!
        @@__server__ = nil
        GC.start
        require_files
        cache_file_mtime
        start_server!
      end

      # 启动服务器
      def start_server!
        @@__server__ = Server.new
        @@__server__.run!
      end
    end
  end
end

