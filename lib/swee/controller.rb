# -*- encoding: utf-8 -*-
require "erb"

module Swee
  # 过滤器
  class FilterStruct
    attr_accessor :type,:method,:actions
    def initialize _t, _m, _a
      @type,@method,@actions = _t,_m,_a
    end
  end

  class Controller
    include ControllerFilter
    attr_reader :env, :request, :controller_name, :action_name, :request #, :response
    
    # 包装request
    # rack 的 request -> controller request
    # .方法的 映射 -> [] 方法
    # Struct 简单的包装
    def warp_request env,route
      @env = env
      @rack_request = Rack::Request.new env  # 暂时用 rack 方式接受 TODO: 解析 env
      # @response = Rack::Response.new
      @controller_name = route.controller_name
      @name = route.controller
      @action_name = route.action
      request_struct =  Struct.new(:hash) do
        def method_missing method_name, *args, &blk
          if hash.key? method_name
            hash[method_name]
          else
            case method_name
            when :remote_ip; hash[:ip]
            when :post?; hash[:method] == "POST"
            when :get?;  hash[:method] == "GET"
            when :xhr?;  hash[:xhr]
            else
              super
            end
          end
        end
      end
      @request = request_struct.new(rack_request_to_hash)
    end

    def _name
      @name
    end

    def rack_request
      @rack_request
    end

    def response
      @response
    end

    # 获取 参数
    def params
      { "controller" => @controller_name, "action" => @action_name }.merge @rack_request.params
    end

    # 映射 rake request -> struct
    def rack_request_to_hash
      _request = rack_request
      _body = {
          ip:                 _request.ip,
          cookies:            _request.cookies,
          session:            _request.session,
          session_options:    _request.session_options,
          referer:            _request.referer,
          user_agent:         _request.user_agent,
          method:             _request.request_method,
          path:               _request.path,
          path_info:          _request.path_info,
          params:             _request.params,
          port:               _request.port,
          url:                _request.url,
          base_url:           _request.base_url,
          fullpath:           _request.fullpath,
          host:               _request.host,
          host_with_port:     _request.host_with_port,
          logger:             _request.logger,
          media_type:         _request.media_type,
          media_type_params:  _request.media_type_params,
          POST:               _request.POST,
          query_string:       _request.query_string,
          scheme:             _request.scheme,
          script_name:        _request.script_name,
          ssl:                _request.ssl?,
          trace:              _request.trace?,
          xhr:                _request.xhr?,
          client:             _request['client']
      }
    end

    # 渲染
    # text:  render :text => "foobar"
    # erb:   render (可省略对应寻找view)
    # json:  render :json => { foo: "bar" }
    def render options={}
      if options.empty?
        _render_file
      else
        if options[:text]
          _render_text options
        elsif options[:json]
          _render_json options
        end
      end
    end

    def rake_format body,type

    end

    # TODO
    def cookies

    end

    # TODO
    def sessions

    end

    def __actions
      ControllerFilter.fliter_methods[self.class.to_s]
    end


    private
    def _render_file(ftype="html")
      if ftype == "html"
        _view = View.new(self)
        _body = _view.create_view
      else
        _body = "no file was loaded!"
      end
      # _length = View.calc_length(_body).to_s
      [200,{ "Content-Type" => "text/html; charset=utf8" },[_body]]
    end

    def _render_text options
      _body = options[:text]
      # _length = View.calc_length(_body).to_s
      [200,{ "Content-Type" => "text/plain; charset=utf8" },[_body]]
    end

    def _render_json options
      _body = options[:json].to_json
      # _length = View.calc_length(_body).to_s
      [200,{ "Content-Type" => "application/json; charset=utf8" },[_body]]
    end

  end
  Controller.define_filter
end