class DeviseInstallGenerator < Rails::Generators::Base
  def self.source_root
    @_devise_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  end
  
  def install_devise
    empty_directory "config/initializers"
    template "devise.rb", "config/initializers/devise.rb"

    empty_directory "config/locales"
    template "../../../devise/locales/en.yml", "config/locales/devise.en.yml"
  end

end
