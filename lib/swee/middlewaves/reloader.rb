module Swee

  class Reloader
    def initialize(app,logger)
      @app = app
      @logger = logger
      app_path = ENV["app_path"]
    end

    def call(env)
      # 快速遍历 文件 mtime cache表
      # mtime不一致则重新 load
      Lodder.mtime_files.each_pair do |file,omtime|
        mtime = File.mtime(file)
        if mtime != omtime
          load file
          Lodder.mtime_files[file] = mtime
          @logger << "#{file}文件已重载!"
        end
      end
      return @app.call(env)
    end
  end
end
