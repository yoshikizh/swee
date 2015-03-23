# -*- encoding: utf-8 -*-
class HomeController < Swee::Controller
  before_filter :set_variable, :only => [:index]

  def index
  end

  private
  def set_variable
    @welcome = "Hello Swee"
  end
end
