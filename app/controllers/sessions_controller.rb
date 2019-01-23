require 'net/http'

class SessionsController < ApplicationController
  
  # After authenticating successfully with Auth0, Auth0 redirects the user
  # back to the `/auth/oauth2/callback` path, which routes to this method.
  # This is where our app starts to process the new session.
  def callback
    # Omniauth makes the response data available from Auth0, and we assign
    # it to a session variable. The presence of this session variable will
    # indicate elsewhere that our app has a logged-in user.
    #
    # See https://github.com/auth0/omniauth-auth0#authentication-hash for
    # details about what user data Auth0 returns.
    #
    # See https://api.rubyonrails.org/classes/ActionController/Base.html#class-ActionController::Base-label-Sessions
    # for more on working with Rails sessions.
    session[:userinfo] = request.env["omniauth.auth"]
    
    # This method, defined in SessionsHelper, does the brunt of the app-side
    # authentication processing.
    authenticate_user!
    
    # '/secure' is our app's destination for newly logged-in users who weren't
    # trying to navigate somewhere else before they were asked to log in.
    redirect_to request.env["omniauth.origin"] || '/secure'
  end

  # If authentication fails with Auth0, Auth0 redirects the user back to the
  # `/auth/failure` path, which routes to this method. This is where we parse
  # the error message and display it to the user.
  def failure
    @error_msg = request.params['message']
    # @error_type = request.params["error_type"]
    # @error_msg = request.params["error_msg"]
    # alert = @error_type || @error_msg ? "#{@error_msg} (type=#{@error_type})" : nil
    # redirect_to login_url params: { return_url: root_url }, alert: alert
  end

  # When a user wishes to log out, s/he simply navigates to navigates to
  # `/logout`, processed by this method. We must both clear the session within
  # our app and notify Auth0, via a redirect, that the user is logging out.
  # Auth0 will redirect back to our app afterwards (per the parameters set in
  # `auth0_logout_url`)
  def logout
    # For more on sessions, see https://api.rubyonrails.org/classes/ActionController/Base.html#class-ActionController::Base-label-Sessions
    reset_session
    # auth0_logout_url is defined in SessionsHelper
    redirect_to auth0_logout_url
  end

  # Auth0 requires the user to click a link in an e-mail to perform a password
  # change. Ugh. Navigate to `/change_password` route, and this method will
  # initiate that process for the user.
  def change_password
    # Only process a password change request if the user is already
    # authenticated.
    authenticate_user!

    # auth0_change_password_uri is defined in SessionsHelper
    uri = auth0_change_password_uri
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri)
    request["content-type"] = 'application/json'
    request.body = auth0_change_password_body

    # This POSTs the request to Auth0 and makes the response available as
    # a variable to be displayed, if you desire, in 
    # `/app/views/sessions/change_password.html.erb`
    @response = http.request(request)
  end
end
