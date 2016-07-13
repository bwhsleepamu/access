class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #layout "contour/layouts/application"


  def about

  end

  def parse_date(date_string)
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue ""
  end

  def parse_search_terms(params)
    params.to_s.gsub(/[^0-9a-zA-Z]/, ' ')
  end

  protected


end
