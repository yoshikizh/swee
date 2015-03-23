module Swee

  # 服务器配置
  server_config do |cfg|

    # 日志文件位置 => [日志文件, 文件数量, 文件大小]
    cfg.log_file     = [ "./logs/development.log", 10, 10240000 ]

    # 日志等级
    cfg.logger_level = :debug

    # 重启模式
    # :touch => 请配置 touch_file, 并指定 restart.txt 文件位置
    # :pid   => 请配置 pid_file, 并制定 pid 文件位置
    cfg.restart_mode = :touch
    cfg.touch_file   = "./tmp/restart.txt"
    cfg.pid_file     = "./tmp/pid"

    # 是否改变代码立刻reload(重载)
    cfg.code_reload  = true

    # 最大连接数
    cfg.max_connections = 1024

    # 是否后台运行(守护进程模式)
    cfg.run_background = false
    
  end

  # 应用配置
  app_config do |cfg|

    # 配置 404 页面路径(相对于项目路径)
    cfg.page404         = "./public/404.html"

  end

end