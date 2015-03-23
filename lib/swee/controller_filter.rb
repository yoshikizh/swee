module Swee
  module ControllerFilter
    @@fliter_methods = Hash.new {|h1,k1| h1[k1] = [] }

    def self.fliter_methods
      @@fliter_methods
    end

    def self.included(base)
      base.extend self
    end

    def find_controller _controller
      fliter_methods[_controller]
    end

    def delete_duplicated_filter _controller,_method
      structs = find_controller _controller
      dup_struct = structs.select { |struct| struct.method == _method }.first
      structs.reject! { |struct| struct.equal?(dup_struct)  }
    end

    def find_filter_methods _controller,_type,_action
      structs = find_controller _controller
      structs.select { |s|
        _actions = s.actions
        unless _actions.empty?
          if s.actions[:only]
            exist_action = s.actions[:only].map(&:to_sym).include?(_action.to_sym)
          elsif s.actions[:except]
            exist_action = !s.actions[:except].map(&:to_sym).include?(_action.to_sym)
          end
        end
        (_actions.empty?   && s.type == _type)  ||
        (_actions.empty?   && s.type == :round) ||
        ( s.type == _type  && exist_action )    ||
        ( s.type == :round &&  exist_action )
      }.map(&:method)
    end

    def fliter_methods
      @@fliter_methods
    end

    def filter! _type, _method, options={}
      delete_duplicated_filter self.name, _method
      fliter_methods[self.name] << FilterStruct.new(_type, _method.to_sym, options) #     {_method => [:before,options] }
      fliter_methods[self.name].uniq!
    end

    def define_filter
      self.class.instance_eval do
        [:before_filter,
         # :skip_before_filter,  TODO:
         :after_filter, 
         # :skip_before_filter,  TODO:
         :round_filter, 
         # :skip_before_filter   TODO:
        ].each do |method_name|
          define_method(method_name) do |_method,options={}|
            filter! method_name.to_s.split("_").first.to_sym, _method, options
          end
        end
      end
    end
  end
end