# rails-auth0-full-example

This app attempts to provide an example of using Auth0 with Ruby on Rails that is more comprehensive and production-ready than [Auth0's published examples](https://github.com/auth0-samples/auth0-rubyonrails-sample).

## Features

* Associates the Auth0 session with a User model, using a find-or-create approach
* Redirects the user to the secured URL originally requested
* Every controller assumed to require authentication unless intentionally excluded
* A simple user page with link for password change
* A logout path/action that redirects the user back to the home page

### Other useful bits

* Excessive comments so my old-man brain won't forget the details
* Keeps sensitive strings in a .env file
* Uses high_voltage for public, unauthenticated page
* (TODO) Tests that cover the session code

## Overview

For more details, read the comments within each file.

### Routes

This app sets up the following routes to handle Auth0 authentication and demonstrate
secure vs. public destinations:

| Route                 | Description |
|-----------------------|-------------|
| `/auth/oauth2/callback` | Processes a successful authentication |
| `/auth/failure`         | Processes an authentication failure |
| `/logout`               | Logs the user out |
| `/change_password`      | Initiates the change password process |
| `/secure`               | A route requiring authentication |
| `/user`                 | Shows the user's account info (also requires authentication) |
| `/`                     | The public home page (no auth necessary) |

### `.env`

Copy `.env.example` to `.env` and fill in each value from your [Auth0 application configuration](https://manage.auth0.com/#/applications). This file is a safe place to put sensitive information like your client ID and secret. (In a production environment, you'd set these environment variables on your server instead. For example, here are [Heroku's instructions](https://devcenter.heroku.com/articles/config-vars).)

### SessionsController

This is the main controller that handles logins, login failures, logouts, and password changes.

### SessionsHelper

A lot of the gnarly details of integrating Auth0 with our app appear here.

### `config/initializers/auth0.rb`

This initializer configures the Omniauth gem to support Auth0. Changes to this file require a server restart.

## Contributing

I'm certain there are cleaner or more elegant ways to code this. Share your ideas in an issue or a pull request.