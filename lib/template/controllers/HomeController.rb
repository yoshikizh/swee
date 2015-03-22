class HomeController < Webber::Controller
  before_filter :set_variable, :only => [:index]

  def index
  end

  private
  def set_variable
    @welcome = "Hello Webber"
  end
end
