module SessionsHelper

  private

    def user_signed_in?
      session["userinfo"].present? && session["userinfo"]["uid"].present?
    end

    # Sets the @current_user if user is already authenticated, otherwise
    # redirects user to login.
    def authenticate_user!
      if user_signed_in?
        @current_user = find_or_create_user_by!(session["userinfo"])
      elsif !authenticate_user_excluded?
        redirect_to "/auth/auth0?origin=#{request.original_url}"
        return
      end

      update_authenticated_user current_user if current_user
    end

    # Finds a user by the Auth0 identifier or creates a new user.
    # Throws an exception if there is a problem creating the user.
    def find_or_create_user_by!(userinfo)
      User.find_by(auth0_id: userinfo["uid"]) ||
        User.create!(auth0_id: userinfo["uid"], email: userinfo["info"]["email"])
    end

    def update_authenticated_user(user)
      # By using update_columns, we can record last_sign_in_at without
      # disturbing the updated_at column
      user.update_columns(last_sign_in_at: Time.now)
    end

    # By default, we assume all requests require authentication. The
    # controllers listed below are the exceptions, which may be accessed
    # without authentication.
    def authenticate_user_excluded?
      %w[pages sessions].include?(controller_name)
    end

    # The Auth0 logout URL must include your Auth0 client ID, and the returnTo
    # URL must be specified in your Auth0 application configuration.
    def auth0_logout_url
      request_params = {
        client_id: ENV['AUTH0_CLIENT_ID'],
        returnTo: root_url
      }

      URI::HTTPS.build(
          host: ENV['AUTH0_DOMAIN'],
          path: "/logout",
          query: request_params.to_query
        ).to_s
    end

    # I really hate this, but this is how Auth0 makes your users
    # reset their password: first, POST to a change_password URL
    # and then receive an e-mail with a link to an Auth0 password
    # change form. So ugly.
    def auth0_change_password_uri
      URI::HTTPS.build(
          host: ENV['AUTH0_DOMAIN'],
          path: "/dbconnections/change_password"
        )
    end

    def auth0_change_password_body
      "{\"client_id\": \"#{ENV['AUTH0_CLIENT_ID']}\",\"email\": \"#{@current_user.email}\",\"connection\": \"Username-Password-Authentication\"}"
    end
end