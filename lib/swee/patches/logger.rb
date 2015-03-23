# -*- encoding: utf-8 -*-
require "logger" if !defined? Logger

class Logger

  # 判断当前日志是否输出到stdout
  def io?
    instance_variable_get(:@logdev).dev === STDOUT
  end


  # 判断当前日志输出到logfile
  def file?
    instance_variable_get(:@logdev).dev.is_a?(File)
  end
end
