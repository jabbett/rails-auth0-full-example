# rails-auth0-full-example

This example attempts to provide a more comprehensive and production-ready
example of using Auth0 with Ruby on Rails.

* Keeps sensitive strings in a .env file
* Connects the Auth0 session with a User model (find or create)
* Redirects the user to the secured URL originally requested
* Every request assumed to require authentication unless intentionally excluded
* A simple user page with link for password change
* A logout path/action that redirects the user back to the home page
* Uses high_voltage for public, unauthenticated page
* Includes tests for the session code