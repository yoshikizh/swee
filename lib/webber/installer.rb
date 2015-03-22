module Webber
  module Installer
    module_function
    def run proj_name

      # 打印安装信息
      puts "--------------- Webber 安装 -----------------"
      proj_dir = "#{Dir.pwd}/#{proj_name}"

      # 创建项目目录
      if Dir.exist?(proj_dir)
        puts "当前路径已存在#{proj_name}目录"
        return
      end
      puts "#{proj_name}目录创建成功"
      Dir.mkdir(proj_dir)

      # 安装目录
      app_path = proj_dir
      ["public","controllers","logs","models","tmp","views","views/home"].each do |dir|
        _dir = app_path + "/#{dir}"
        if Dir.exist?(_dir)
          puts "#{_dir}目录已存在,略过..."
        else
          Dir.mkdir(_dir)
          puts "#{_dir}目录成功创建"
        end
      end

      # 安装 文件
      ["config.rb","routes.rb","public/404.html","controllers/HomeController.rb", "views/home/index.erb"].each do |_file|
        file = app_path + "/#{_file}"

        if File.exist?(file)
          puts "#{file} 已经安装过了"
        else
          f = File.open(file,"w")
          config_file = File.expand_path("../template/#{_file}",File.dirname(__FILE__))
          f.write(File.read(config_file))
          f.close
          puts "#{file} 已经安装"
        end
      end

      # 打印结束信息
      puts "恭喜,全部安装完成"
      puts "您可以先输入: webber s 来启动服务器"
      puts "请打开config.rb 和 routes.rb 配置所需的参数"
      puts "更多参数请输入: webber --help"
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      puts "我们先启动一个欢迎页面"
      puts "浏览器输入 http://localhost:3000 来访问欢迎页面吧"
      puts "按 Ctrl + C 关闭服务"
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      `cd #{proj_name} && webber s`
    end
  end
end