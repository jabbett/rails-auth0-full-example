HighVoltage.configure do |config|
  # Requests for the root path will be served by the static 'home' page
  # View is located at app/views/pages/home.html.erb
  config.home_page = 'home'
end