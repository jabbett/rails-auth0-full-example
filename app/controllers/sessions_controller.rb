require 'net/http'

class SessionsController < ApplicationController
  def callback
    # See https://github.com/auth0/omniauth-auth0#authentication-hash
    session[:userinfo] = request.env["omniauth.auth"]
    authenticate_user!
    redirect_to request.env["omniauth.origin"] || '/secure'
  end

  def failure
    @error_msg = request.params['message']
    # @error_type = request.params["error_type"]
    # @error_msg = request.params["error_msg"]
    # alert = @error_type || @error_msg ? "#{@error_msg} (type=#{@error_type})" : nil
    # redirect_to login_url params: { return_url: root_url }, alert: alert
  end

  def change_password
    authenticate_user!

    uri = auth0_change_password_uri
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri)
    request["content-type"] = 'application/json'
    request.body = auth0_change_password_body

    @response = http.request(request)
  end

  def logout
    reset_session
    redirect_to auth0_logout_url
  end
end
