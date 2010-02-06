require 'devise'
require 'rails'

DEVISE_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

module Devise
  class Railtie < Rails::Railtie
    railtie_name :devise

    def load_paths
      Dir["#{DEVISE_PATH}/app/{mailers,controllers,helpers}"]
    end
    
    # TODO: 'after' and 'before' hooks appear to be broken
    # Some initialization can't take place here until this bug is fixed:
    # - alias_method_chain in rails/routes.rb

    initializer "devise.add_to_load_path", :after => :set_autoload_paths do |app|
      load_paths.each do |path|
        $LOAD_PATH << path
        require "active_support/dependencies"

        ActiveSupport::Dependencies.load_paths << path

        unless app.config.reload_plugins
          ActiveSupport::Dependencies.load_once_paths << path
        end
      end
    end

    initializer "devise.add_view_paths", :after => :initialize_framework_views do
      views = "#{DEVISE_PATH}/app/views"
      ActionController::Base.view_paths.concat([views]) if defined? ActionController
      ActionMailer::Base.view_paths.concat([views])     if defined? ActionMailer
    end
    
    initializer "devise.load_routes_and_warden_compat" do |app|
      require 'devise/rails/routes'
      require 'devise/rails/warden_compat'
    end
    
    initializer "devise.add_middleware", :before => :build_middleware_stack do |app|
      # Adds Warden Manager to Rails middleware stack, configuring default devise
      # strategy and also the failure app.
      app.config.middleware.use Warden::Manager do |config|
        Devise.configure_warden(config)
      end
    end

    initializer "devise.after_initialize", :after => :after_initialize do |app|
      # TODO: this needs to be done in the user's configuration
      # until initializer dependencies work properly 
      #require "devise/orm/#{Devise.orm}"

      I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), 'locales', 'en.yml'))
    end
  end
end
