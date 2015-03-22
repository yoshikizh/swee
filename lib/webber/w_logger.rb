require "fiber"

class Webber::WLogger
  def initialize
    @logs = Array.new
    @msg = Array.new
    init_fiber
  end

  def init_fiber
    @fb = Fiber.new { loop_log }
  end

  def loop_log
    loop do
      each_log
      Fiber.yield
    end
  end

  def each_log
    while !@msg.empty?
      _msg = @msg.shift
      @logs.each { |_log| _log.debug _msg }
    end
  end

  def get_binding
    binding
  end

  def roll!
    each_log
    # Fiber 存在跨线程问题 暂时不用Fiber处理
    # init_fiber if !@fb.alive?
    # @fb.resume
  end

  def addlog log
    @logs << log
  end

  def get_io
    @logs.select { |log| log.io? }.first
  end

  def get_file
    @logs.select { |log| log.file? }.first
  end

  def logs
    @logs
  end

  def <<(msg)
    @msg << msg
    roll!
  end
end
