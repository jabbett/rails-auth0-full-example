class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :authenticate_user!
  helper_method :user_signed_in?, :current_user

  attr_reader :current_user
end
