module Webber
  class Routes
    @@tables = {}
    class RouteStruct
      attr_reader :controller, :action, :request_methods
      def initialize c,a,m
        @controller,@action,@request_methods = c,a,m
      end

      def controller_name
        "#{controller[0].upcase+controller[1..controller.size-1]}Controller"
      end

      def create_controller_instance
        eval "#{controller_name}.new"
      end
    end
    class << self

      def get *args
        self._parse "get",*args
      end

      def post *args
        self._parse "post",*args
      end

      def match *args
        self._parse "match",*args
      end

      def tables
        @@tables
      end

      def _parse _m,*args
        _path_info = args[0].to_s
        if args[1] =~ /^(.*)#(.*)$/
          @@tables[_path_info] = RouteStruct.new $1,$2, _m == "match" ? args[2][:via].map(&:to_sym) : [_m.to_sym]
        else
          raise "routes error!"
        end
      end
    end
  end
end