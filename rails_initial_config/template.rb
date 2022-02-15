# frozen_string_literal: true
#gem "rails", git:'https://github.com/rails/rails.git', branch: 'main'
# 1/11/22 - rails 7.0.1 released ! this shouldn't be needed currently
def rails_main_gem
  <<~'END_STRING'
    gem "rails", git:'https://github.com/rails/rails.git', branch: '7-0-stable'
  END_STRING
end

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'webdrivers'
  gem 'faker'
end

def generators_rb
  <<-CODE
  Rails.application.config.generators do |g|
    g.test_framework :rspec,
     fixtures: false,
     view_specs: false,
     helper_specs: false,
     routing_specs: false,
     request_specs:false,
     controller_specs: false
  end
  CODE
end

after_bundle do
  generate 'rspec:install'
end

#gsub_file 'Gemfile', /gem "rails",.*/, rails_main_gem
initializer 'generators.rb', generators_rb
