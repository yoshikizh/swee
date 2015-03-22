module Webber
  class AppExecutor

    class << self
      # 启动 app 渲染器
      # app_path 转路由
      # 执行 app controller 方法
      # 渲染 filter (:before, :after, :round)
      # 生成 View
      def run env
        route = path_to_route(env)
        request_method = env["REQUEST_METHOD"].downcase.to_sym
        if route.nil? || !route.request_methods.include?(request_method)
          return View.render_404
        end
        controller_intance = route_to_controller route, env
        render_view controller_intance, route
      end

      # app_path转路由
      # 获取 路由结构
      def path_to_route env
        _path_info = env["PATH_INFO"]
        Routes.tables[_path_info.to_s]
      end

      # 执行 app controller 方法
      def route_to_controller route, env
        controller = route.controller
        controller_intance = route.create_controller_instance
        controller_intance.warp_request env,route
        controller_intance
      end

      # 渲染视图
      # 渲染 -> 前置 后置 环绕控制器
      def render_view controller_intance, route
        execute_before_filter controller_intance, route
        result = execute_controller controller_intance, route.action
        execute_after_filter controller_intance, route
        return !rack_responsed?(result) ? controller_intance.render : result
      end

      # 执行前置过滤器
      def execute_before_filter controller_intance,route
        execute_filter :before, controller_intance, route
      end

      # 执行后置过滤器
      def execute_after_filter controller_intance,route
        execute_filter :after, controller_intance, route
      end

      # 执行控制器
      def execute_controller controller_intance,action
        result = controller_intance.send(action)
        result.freeze
        result
      end

      # 执行过滤器
      def execute_filter _type, controller_intance,route
        _filter_actions = Controller.find_filter_methods route.controller_name,_type,route.action
        _filter_actions.each do |_action|
          controller_intance.send _action
        end
      end

      # 检测是否为 rack 格式得响应
      # rack标准格式: [status,headers,[body]]
      def rack_responsed? result
        if result.is_a?(Array) && result.size == 3
           status =  result[0]
          headers =  result[1]
             body =  result[2]
          if status.is_a?(Integer) && headers.is_a?(Hash) && body.respond_to?(:each)
            return true
          end
        end
        return false
      end
    end

    DEFAULT_THTEADS = 20

    # TODO: 多线程处理控制器和路由
    class ExeThread
      DEFAULT_SLEEP = 0.5
      @t = nil
      def initialize
        @mission_queue = []
      end

      def run
        while true
          if @mission_queue.empty?
            wait
          else
            @mission_queue.shift.call()
          end
        end
      end

      def create!
        @t = Thread.new { run }
      end

      def busy?
        !@mission_queue.empty?
      end

      def << mission
        @mission_queue << mission
        create! if @t.dead?
      end

      def wait
        sleep DEFAULT_SLEEP
      end
    end

    def initialize
      @queue = []
      @threadpoll = Array.new
      DEFAULT_THTEADS.times do
        @threadpoll << ExeThread.new
      end
    end

    def current_thread
      _current_thread = @threadpoll.select { |t| !t.busy? }
    end

    def run
      f = Fiber.new do
        while true
          Fiber.yield
        end
      end
    end

    def wait
      while exist_alive_thread?
        sleep 0.1
      end
    end

    def <<()
      @queue.push()
    end
  end
end