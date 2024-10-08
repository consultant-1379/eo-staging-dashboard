require 'dotenv'
Dotenv.load
require 'dashing'
require 'logger'


configure do
  set :auth_token, ENV['AUTH_TOKEN']

  
  helpers do
    def protected!
      #settings.logger.info "I'm inside a helper"
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
