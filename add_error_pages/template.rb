# frozen_string_literal: true
require_relative '../lib/addon_helpers'
# require_relative '../lib/thor_addons'
#
# class << self
#   include ThorAddons
# end

## ====================================
## Boilerplate for all templates: START
## bootstrap template utilities from
## repo if not found locally
## ------------------------------------
# try local load
def local_require(filename, relative_path)
  relative_flname = File.join(relative_path, filename)
  require_relative(relative_flname)
end

# try loading locally first, try repo version on load error
# caution: only use with files you control access to!
def repo_require(raw_repo_prefix, filename, relative_path = '')
  local_require(filename, relative_path)

rescue LoadError => e
  puts e.message
  require 'open-uri'

  tempdir = Dir.mktmpdir("repo_require-")
  temp_flname = File.join(tempdir, File.basename(filename))
  return false if $LOADED_FEATURES.include?(temp_flname)

  remote_flname = File.join(raw_repo_prefix, filename)
  puts "file not found locally, checking repo: #{remote_flname}"
  begin
    File.open(temp_flname, 'w') do |f|
      f.write(URI.parse(remote_flname).read)
    end
  rescue OpenURI::HTTPError => e
    raise "Error: Can't load #{filename} from repo: #{e.message} - #{remote_flname}"
  end
  require(temp_flname)
  FileUtils.remove_entry(tempdir)
end
## ------------------------------------
## Boilerplate for all templates: END
## ====================================

def add_error_routes
  app_filename = "config/routes.rb"
  insert_into_file(app_filename, before: /^end/) do
    <<-RUBY
  match '/404', to: 'errors#not_found', via: :all, as: :not_found_error
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/403', to: 'errors#forbidden_error', via: :all
    RUBY
  end
end

def update_error_config
  app_filename = 'config/application.rb'
  insert_into_file(app_filename, after: %r{config.load_defaults 7.0 *\n}m) do
    "    config.exceptions_app = routes\n"
  end
end

# tailwind updated devise views
def copy_error_controller_and_views
  errors_controller_file = 'app/controllers/errors_controller.rb'
  copy_file(AddonHelpers.source_dir(errors_controller_file), errors_controller_file)

  errors_views_dir = 'app/views/errors'
  #run "rm -fr #{errors_views_dir}"
  directory AddonHelpers.source_dir(errors_views_dir), errors_views_dir
end

def add_error_pages
  copy_error_controller_and_views
  update_error_config
  add_error_routes
end

repo_require('https://raw.githubusercontent.com/rlogwood/rails_addons/main',
             'lib/config_paths.rb', '..')

repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)
puts "Template directory is #{template_dir}"

add_error_pages
