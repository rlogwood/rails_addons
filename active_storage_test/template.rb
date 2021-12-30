# frozen_string_literal: true
require_relative '../lib/thor_addons'

class << self
  include ThorAddons
end

# initialize generic template helpers
require_relative '../lib/template_helpers'
initialize_template_helpers(__FILE__)

# default scaffold model for testing ActiveStorage 
DEFAULT_MODEL = 'TestPost'.tableize.singularize

def install_active_storage
  rails_command "active_storage:install"
end

def scaffold_form_filename(model_name)
  "app/views/#{model_name.pluralize}/_form.html.erb"
end

def scaffold_view_show_filename(model_name)
  "app/views/#{model_name.pluralize}/show.html.erb"
end

def scaffold_model_filename(model_name)
  "app/models/#{model_name}.rb"
end

def scaffold_controller_filename(model_name)
  "app/controllers/#{model_name.pluralize}_controller.rb"
end

def scaffold_exists?(model_name)
  model_filename = scaffold_model_filename(model_name)
  form_filename = scaffold_form_filename(model_name)

  puts "* checking if scaffolding has already been generated for (#{model_name})..."
  puts "* checking #{model_filename} ..."
  puts "* checking #{form_filename} ..."
  File.exist?(model_filename) || File.exist?(form_filename)
end

def choose_model_name
  model_name = nil
  loop do
    model_name = ask('What name do you want to use for the scaffold model (use snake or camel case)?', default: DEFAULT_MODEL)
    model_name = model_name.tableize.singularize
    break unless scaffold_exists?(model_name)

    puts "\n***\n*** The scaffolding for >>>(#{model_name})<<< already exists, please pick another name\n***\n"
    puts "Choose another name or Ctrl-C out and remove it with bin/rails destroy and run the template again"
  end
  model_name
end

# generate scaffold for model and updated as needed for ActiveStorage test
def create_example_scaffold_with_active_storage(model_name)
  puts "\n*** Generating scaffolding for (#{model_name})"
  generate(:scaffold, model_name, 'title:string', 'body:text')

  # each instance of model will have a collection of ActiveStorage items called :files
  inject_into_class(scaffold_model_filename(model_name),model_name.camelize) { "  has_many_attached :files\n" }

  # view add-ins for editing and showing files collection
  form_addition_filename = template_full_filename('views/_form_addition.html.erb')
  show_addition_filename = template_full_filename('views/show_addition.html.erb')

  # NOTE: make additions to form and views generic as possible to accommodate custom templates

  # add files uploader to generic scaffold form
  form_regex = %r{text_area :body[^%]+%>\n *</div>\n}m
  insert_into_file(scaffold_form_filename(model_name), after: form_regex) { File.read(form_addition_filename) }

  # add files links to the scaffold show form
  additional_show_info = File.read(show_addition_filename).gsub('{#model_name}', model_name)
  show_view_regex = /\.body[^%]+%>[^\n]*\n/m
  insert_into_file(scaffold_view_show_filename(model_name), after: show_view_regex) { additional_show_info }

  # update permitted parameters for model
  update_scaffold_controller_permitted_params(model_name)
end

# configure DigitalOcean bucket for ActiveStorage
def update_storage_yml
  storage_additions_filename = template_full_filename('lib/active_storage_config/storage_additions.yml')

  storage_config_filename = 'config/storage.yml'
  raise("Storage config not found (#{storage_additions_filename})") unless File.exist? storage_additions_filename

  my_bucket_name = ask('What is your Digital Ocean spaces S3 bucket name?')
  bucket_placeholder = 'bucket: (my bucket name)'
  my_bucket = "bucket: #{my_bucket_name}"
  append_to_file(storage_config_filename) { File.read(storage_additions_filename)}
  gsub_file(storage_config_filename, bucket_placeholder, my_bucket)
end

# add ActiveStorage :files to permitted parameters
def update_scaffold_controller_permitted_params(model_name)
  new_params = <<~END_STRING
      def #{model_name}_params
        params.require(:#{model_name}).permit(:title, :body, files: [])
      end
    end
  END_STRING

  # params_regex = %r{ *def #{model_name}_params\n.*\n *end\n}m
  params_regex = / *def #{model_name}_params\n.*\n *end\n/m
  gsub_file(scaffold_controller_filename(model_name), params_regex, new_params)
end

# add ActiveStorage support for direct uploads from javascript
def update_application_js
  application_js_filename = application_js_filename_for_webpacker

  append_to_file(application_js_filename, 'import "../src/direct_uploads"')

  copy_file(template_relative_filename('javascript/direct_uploads.js'),
            File.join(webpacker_javascript_files_dir, 'direct_uploads.js'),
            force: true)
end

# add ActiveStorage css for direct upload form fields
def update_css
  copy_file(template_relative_filename('stylesheets/direct_uploads.css'),
            File.join(additional_stylesheets_dir, 'direct_uploads.css'))

  return if asset_pipeline_app?

  append_to_file(application_stylesheet_filename, '@import "../stylesheets/direct_uploads.css";')
end

# copy and customize CORS configuration for DigitalOcean buckets
def copy_cors_config
  app_cors_filename = 'lib/active_storage_config/digital_ocean/cors.xml'
  heroku_app_placeholder_origin = '<AllowedOrigin>https://(myherokuapp).herokuapp.com</AllowedOrigin>'

  my_app_name = ask('What your heroku app name?')
  heroku_my_app_origin = "<AllowedOrigin>https://#{my_app_name}.herokuapp.com</AllowedOrigin>"
  run "heroku apps:info #{my_app_name}"

  puts "Updating CORS xml file (#{app_cors_filename})..."
  puts "Adding heroku origin: (#{heroku_my_app_origin})"

  copy_file(template_relative_filename('lib/active_storage_config/digital_ocean/cors.xml'), app_cors_filename, force: true)
  gsub_file(app_cors_filename, heroku_app_placeholder_origin, heroku_my_app_origin)
end

# use digital ocean spaces in development and production
def update_environments
  active_storage_service = 'config.active_storage.service = :spaces'
  gsub_file('config/environments/production.rb', /config.active_storage.service = :local/, active_storage_service)
  gsub_file('config/environments/development.rb', /config.active_storage.service = :local/, active_storage_service)
end

# make root route point to new test model scaffold created for this ActiveStorage test
def update_root_route(model_name)
  root_route = "root to: '#{model_name.pluralize}#index'"
  routes_filename = File.join(destination_root,'config','routes.rb')
  if file_has_string(routes_filename, /root/)
    result = gsub_file('config/routes.rb', /root .*$/, root_route)
  else
    route root_route
  end
end

# don't commit RubyMine, emacs backups or ruby version files
def update_gitignore
  append_to_file('.gitignore', "\n.idea\n.ruby-version\n*~\n")
end

# basic Procfile for Heroku
def copy_procfile
  copy_file(template_relative_filename('Procfile'), 'Procfile')
end

# add needed S3 gem that facilitates the ActiveStorage connection with DigitalOcean spaces
def update_gemfile
  gem 'aws-sdk-s3'
  do_bundle
end

# update application configuration to allow ActiveStorage updates to add to existing collection for model instance
def update_application_rb
  active_storage_config = "\n\n    # allow active storage updates to add to existing collection\n    config.active_storage.replace_on_assign_to_many = false\n"
  insert_into_file('config/application.rb', before: /^  end\nend/m) { active_storage_config }
end

# perform the steps add an ActiveStorage test to the application
def add_active_storage
  install_active_storage
  model_name = choose_model_name
  create_example_scaffold_with_active_storage(model_name)
  update_storage_yml
  update_application_js
  update_css
  update_root_route(model_name)
  update_environments
  update_application_rb
  copy_cors_config
  update_gitignore
  copy_procfile
  update_gemfile
end

puts("Create active storage example with asset pipeline css and webpacker js")
add_active_storage
