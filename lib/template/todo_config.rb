module Swee

  # 应用配置
  app_config do |cfg|
    cfg.time_zone       = "Beijing"
    cfg.default_locale  = "zh-CN"
    cfg.include_path    = ["./initialize"]
    cfg.email           = {
      domain:   "xxx.xxx.com",
      username: "xxxx",
      password: "123456"
    }
  end

  # 服务器配置
  server_config do |cfg|

    # 处理请求方式
    cfg.handle_request_mode = :event_loop
    # cfg.handle_request_mode :thread

    # 性能监控
    cfg.performance_monitoring = true

  end



  app_plugin_cfg do |cfg|
    cfg.user_system do |us|
      us.password_enpty :md5       # md5 或  sha2
      us.password_enpty_length 16  # 16位 或 32位

      us.third_part_login_include :qq, 
                                  pid: "xxxxxxxxxxxx",
                                  sid: "xxxxxxxxxxxx",
                                  username: "xxxxxxxxxxxxxx"

      us.third_part_login_include :weibo, 
                                  pid: "xxxxxxxxxxxx",
                                  sid: "xxxxxxxxxxxx",
                                  username: "xxxxxxxxxxxxxx"

    end

    cfg.uploader do |upl|
      upl.image_pattern = /jpg|jpeg|gif|png|bmp/
      upl.max_magabyte = 20

      cut do |s|
        s[:large] = { size: [1280,960], type: "#" }
        s[:mid]   = { size: [640,480], type: "#" }
        s[:thumb] = [ size: [320,240], type: "#" }
      end
    end
    cfg.payments do |pm|
      pm.pid = "xxxxxxxx"
      pm.sid = "xxxxxxxx"
      pm.email = "xxxxxxxxxxxxx"
    end
  end

  # 数据库配置
  database_config do |cfg|
    cfg.adapter   = :mysql2
    cfg.database  = :timeboxs_development
    cfg.host      = :localhost
    cfg.username  = :root
    cfg.password  = ""
    cfg.encoding  = :utf8
    cfg.pool      = 5
  end


end