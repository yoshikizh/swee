# -*- encoding: utf-8 -*-
require "erb"
# require "cgi"

module Swee

  module Helper
    def raw text
      text.html_safe
    end

    def image_tag

    end

    def form_for

    end

    def tag(name, options = nil, open = false, escape = true)

      "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
    end

    def parse_tag_options options

    end

  end
end
