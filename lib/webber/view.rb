require "erb"

module Webber
  class View
    include Helper
    def initialize controller
      @controller = controller
      @config = Webber.config.app
      get_binding
    end

    # 把controller 实变量绑定到 view 层
    def get_binding
      @controller.instance_variables.each do |v|
        instance_variable_set v, @controller.instance_variable_get(v)
      end
    end

    # 读取视图文件
    # controller/action.erb
    def create_view
      erb = ::ERB.new(File.read(File.expand_path("views/#{@controller._name}/#{@controller.action_name}.erb", ENV["app_path"])))
      erb.result(binding)
    end

    class << self
      # 404页面
      def render_404
        cfg = Webber.config.app
        body = ::ERB.new(File.read(File.expand_path(cfg["page404"], ENV["app_path"]))).result
        headers = { "Content-Type" => "text/html; charset=utf8" }
        [200,headers,[body]]
      end
    end
  end
end