module SessionsHelper

  private

    # True if the user has an active sessions with "userinfo" and
    # "userinfo.uid" set, i.e. we've previously received a successful
    # authentication response from Auth0.
    def user_signed_in?
      session["userinfo"].present? && session["userinfo"]["uid"].present?
    end

    # Sets the @current_user if user is already authenticated, otherwise
    # redirects user to login.
    def authenticate_user!
      if user_signed_in?

        # Finds the current user within our database or creates a new user
        # record with the provided Auth0 data, if one doesn't exist yet.
        # This approach allows anyone to create new accounts within our app.
        # You'll want to change this logic if you don't support off-the-street
        # sign-ups.
        @current_user = find_or_create_user_by!(session["userinfo"])

        # This records the last login time each time someone authenticates
        update_authenticated_user current_user

      elsif !authenticate_user_excluded?

        # This path is made available by Omniauth for authentication with
        # the Auth0 provider. We include the `origin` parameter so that
        # Omniauth will redirect the user back to where s/he was headed
        # before the authentication process began.
        redirect_to "/auth/auth0?origin=#{request.original_url}"
        return

      end
    end

    # Finds a user by the Auth0 identifier or creates a new user.
    # Throws an exception if there is a problem creating the user.
    def find_or_create_user_by!(userinfo)

      # For each person who signs up, Auth0 genreates a unique identifier,
      # which is passed to us during authentication. We use this "uid" to
      # create a User model on our end, which we can integrate more fully
      # into our app.
      #
      # You may want to copy over more data from Auth0 into your User model.
      # See https://github.com/auth0/omniauth-auth0#authentication-hash for
      # details about what additional user data Auth0 may return.
      User.find_by(auth0_id: userinfo["uid"]) ||
        User.create!(auth0_id: userinfo["uid"], email: userinfo["info"]["email"])

    end

    # Update the user's record with last login time. It's nice to know.
    def update_authenticated_user(user)
      # By using update_columns, we can record last_sign_in_at without
      # disturbing the updated_at column
      user.update_columns(last_sign_in_at: Time.now)
    end

    # By default, we assume all requests require authentication. (This is more
    # secure than the opposite.) The controller names listed below are the 
    # exceptions, which may be accessed without authentication. Add additional
    # names to reflect the public controllers in your app.
    def authenticate_user_excluded?
      %w[pages sessions].include?(controller_name)
    end

    # When the user logs out, we tell Auth0 to log the user out on their end,
    # too. This method generates an Auth0 logout URL: it must include your
    # Auth0 client ID, and the returnTo URL must be specified in your Auth0
    # application configuration.
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

    # Generates an Auth0 change-password URL.
    def auth0_change_password_uri
      URI::HTTPS.build(
          host: ENV['AUTH0_DOMAIN'],
          path: "/dbconnections/change_password"
        )
    end

    # Generates the request body that's POSTed to the Auth0 change-password
    # URL. It must include your Auth0 client ID and the user's e-mail address.
    def auth0_change_password_body
      "{\"client_id\": \"#{ENV['AUTH0_CLIENT_ID']}\",\"email\": \"#{@current_user.email}\",\"connection\": \"Username-Password-Authentication\"}"
    end
end