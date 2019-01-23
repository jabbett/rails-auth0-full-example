Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    # These keys should be defined in your `.env` file
    ENV['AUTH0_CLIENT_ID'],
    ENV['AUTH0_CLIENT_SECRET'],
    ENV['AUTH0_DOMAIN'],
    callback_path: '/auth/oauth2/callback',
    # The `scope` below tells Auth0 what data/permissions you want
    # See https://auth0.com/docs/scopes/current
    authorize_params: {
      scope: 'openid profile email'
    }
  )
end