module Swee
  class Server
    include Daemonize

    attr_reader :code_reload

    def initialize
      @config = Swee.config
      @options = @config.server

      @signature = nil

      @handle_request_mode = @options[:handle_request_mode]
      
      @restart_mode = @options[:restart_mode]
      @pid_file   = File.expand_path(@options[:pid_file],ENV["app_path"])
      @touch_file = File.expand_path(@options[:touch_file],ENV["app_path"])

      @logger                         = nil
      @log_file_options               = @options[:log_file]
      @log_file                       = File.expand_path(@log_file_options.first,ENV["app_path"])
      @log_file_options[0]            = @log_file

      @logger_level                   = @options[:logger_level]

      @code_reload                    = @options[:code_reload]

      # 最大连接数 和 稳定连接处
      @maximum_connections            = @options[:max_connections]
      @maximum_persistent_connections = @options[:max_connections]

      # 监听端口
      @listen = @options[:listen]

      # 实际连接 __id__ => connection 
      @connections                    = {}

      # 超时时间
      @timeout                        = 30

      # 活动连接数
      @persistent_connection_count    = 0

      # touch 模式重启时间
      @restart_time = nil

      # 信号队列 暂时只处理 :USR2
      @signal_queue = []

      # 守护进程
      @daemonize = @options[:run_background]

      # todo: 性能监控
      # @performance_monitoring = @options[:performance_monitoring]
    end

    # 获取 Logger STDOUT 和 File
    def logger
      @logger
    end

    # 删除pid文件 用于重启 和 exit
    def remove_pid_file
      File.delete(@pid_file) if @pid_file && File.exists?(@pid_file)
    end

    # 读取pid文件 用于 USR2 信号获得后和Process.pid 比对
    def read_pid_file
      File.read(@pid_file)
    end

    # 写入Process.pid到 pid 文件
    def write_pid_file
      open(@pid_file,"w") { |f| f.write(Process.pid) }
      File.chmod(0644, @pid_file)
    end

    # 是否运行标志
    def running?
      @running
    end

    # 强制停止
    def stop!
      @running  = false
      disconnect
      EventMachine.stop
      @connections.each_value { |connection| connection.close_connection }
    end

    # 放入 注册的 exit_at 函数中
    # 重启 停止服务 -> 删除pid文件 -> 退出进程
    #
    def restart
      stop!
      remove_pid_file
      exit
    end

    # 处理日志 stdout 和 file 两种
    def handle_logger
      # 创建日志文件
      if !File.exist?(@log_file)
        FileUtils.mkdir_p File.dirname(@log_file)
      end
      logs = []
      logs << Logger.new(*@log_file_options)
      unless @daemonize
        logs << Logger.new(STDOUT)
      end

      # todo: 日志等级, datetime, 格式配置
      # logs.each do |_logger|
      #   _logger.level = @logger_level

      #   _logger.datetime_format = '%Y-%m-%d %H:%M:%S'
      #   _logger.formatter = proc do |severity, datetime, progname, msg|
      #     "Started GET #{msg} at #{datetime}"
      #   end
      # end

      @logger = SweeLogger.new

      logs.each { |_logger| @logger.addlog _logger }
    end

    # 处理重启
    def handle_restart
      send "handle_" + @restart_mode.to_s + "_restart"
    end

    # 处理touch重启方式
    def handle_touch_restart
      @restart_time = File.mtime(@touch_file)
    end

    # 处理pid重启方式
    def handle_pid_restart
      write_pid_file
    end

    # 判断是否为 touch 重启方式
    def touch_mode?
      @restart_mode == :touch
    end

    # 判断是否为 USR2 pid 重启方式 
    def pid_mode?
      @restart_mode == :pid
    end

    # 判断 pid 文件是否为 当前进程ID
    def current_pid? pid
      read_pid_file == Process.pid.to_s
    end

    # 追踪重启 EM Timer 方式
    # 每秒执行一次
    # touch: 每秒读取touch文件 mtime
    # pid: trap usr2 信号放入 信号队列, 然后每秒追踪队列变化获取信号
    def trace_restart
      if touch_mode?
        EM.add_periodic_timer(1) {
          mtime = File.mtime(@touch_file)
          if mtime != @restart_time
            @restart_time = mtime
            puts "重启了"
            restart
            # 放弃 next_tick 原因：会在下次有请求时处理重启
            # EM.next_tick { restart }
          end
        }
      end

      if pid_mode?
        EM.add_periodic_timer(1) {
          signal = @signal_queue.shift
          case signal
          when nil
          when :QUIT # graceful shutdown
          when :TERM, :INT # immediate shutdown
            stop!
          when :USR1 # rotate logs
          when :USR2 # exec binary, stay alive in case something went wrong
            _restart = current_pid?
          when :WINCH
          when :TTIN
          when :TTOU
          when :HUP
          end
          restart if _restart
        }
        trap(:USR2) {
          # 收到 USR2信号加入 信号队列
          @signal_queue << :USR2
        }
      end
    end

    # 处理守护进程(后台运行)
    # 创建子进程
    # 进程命名
    # 注册守护进程重启
    def handle_daemonize
      # 先删除pid文件
      remove_pid_file

      # todo 关闭io 管道
      # rd, wr = IO.pipe
      # grandparent = $$

      # 创建子进程
      safefork && exit

      # 设定进程名称
      $0 = "swee"
      
      # 重新创建pid文件
      write_pid_file

      # 注册守护进程重启
      at_exit{
        # 简单的用异常判断 系统退出，并非其他异常 获得重启
        if $!.class == SystemExit
          @logger << "Swee服务器重启!"
          remove_pid_file
          ::Swee::Engine.restart_server!
        end
      }
    end

    # 创建日志 和 pid 文件
    def create_touch_and_pid_file
      [@pid_file,@touch_file].each do |_file|
        if !File.exist?(_file)
          FileUtils.mkdir_p File.dirname(_file)
          open(_file,"w")
          File.chmod(0644, _file)
        end
      end
    end

    # 启动服务器
    def run!
      # 创建日志和pid文件
      create_touch_and_pid_file
      # 处理日志
      handle_logger
      # 处理重启
      handle_restart
      # EM默认配置
      EventMachine.threadpool_size = 20
      EventMachine.epoll
      EventMachine.set_descriptor_table_size(@maximum_connections)

      @logger << "正在启动swee服务器"

      EventMachine::run {
        @signature = connection
        @running = true

        # EM启动后处理后台守护进程运行
        handle_daemonize if @daemonize

        # 追踪重启文件
        trace_restart

        puts "swee 服务器已启动, 端口:#{@listen}"
      }
    end

    # 连接
    def connection
      EventMachine::start_server "0.0.0.0", @listen, Connection do |_connection|
        _connection.server                  = self

        # 记录活动连接数
        if @persistent_connection_count < @maximum_persistent_connections
          @persistent_connection_count += 1
        end
        @connections[_connection.__id__] = _connection
      end
    end

    # 断开
    def disconnect
      EventMachine.stop_server(@signature)
    end

    # 完成连接
    def connection_finished(connection)
      @persistent_connection_count -= 1
      @connections.delete(connection.__id__)
      
      # TODO: 停止或重启
    end
  end
end