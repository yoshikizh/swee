module Swee
  module Lodder
    @@mtime_files_cache = {}

    CACHE_FILE_MTIME_DIR = ["models","controllers"]
    EXTENSION_NAMES = [".rb",".erb",".haml",".slim","ymal"]

    module_function

    def cache_file_mtime
      CACHE_FILE_MTIME_DIR.each { |d| Lodder.search_app_file(d) }
    end

    def mtime_files
      @@mtime_files_cache
    end

    # 递归寻找目录下所有文件
    # 保存为如下结构(用于 代码修改 reload)
    # filename => mtime
    def search_app_file dir
      app_path = ENV["app_path"]
      Dir.glob("#{app_path}/#{dir}/*") do |file|
        if EXTENSION_NAMES.include? File.extname(file).downcase
          @@mtime_files_cache[file] = File.mtime(file)
        else
          if File.directory?(file)
            search_app_file(dir + "/" + file.split("/").last)
          end
        end
      end
    end

    def base_require
      require_relative './support'
      require_relative './config'
      # require_relative './application'

      # patches
      require_relative './patches/logger.rb'

      # app
      require_relative './routes'
      require_relative './helper'
      require_relative './controller_filter'
      require_relative './controller'
      require_relative './view'
      require_relative './app_executor'

      # middlewaves
      require_relative './middlewaves/content_length'
      require_relative './middlewaves/common_logger'
      require_relative './middlewaves/reloader'

      # thin
      require_relative './thin/headers'
      require_relative './thin/request'
      require_relative './thin/response'

      # server
      require_relative './swee_logger'
      require_relative './daemonize'
      require_relative './connection'
      require_relative './server'
      require_relative './exception'

    end

    # 用户配置
    def app_require
      # require_relative './application'
      begin
        require File.expand_path('config', ENV["app_path"])
      rescue LoadError
        raise "未找到config.rb" 
      end
    end

    # 条件读取
    def conditional_require
      # 存在 AR 读取
      unless Gem.find_files("active_record").empty? 
        require 'active_record'
      end
    end

    def all
      conditional_require
      require "thin_parser"
      base_require
    end
  end
end
