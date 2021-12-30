# frozen_string_literal: true
require_relative '../lib/addon_helpers'
require_relative '../lib/thor_addons'

class << self
  include ThorAddons
end

# Running locally example:
# template="~/src/repos/public/rails_addons/add_devise/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/add_devise/template.rb"

# Apply the template
# bin/rails app:template LOCATION=$template --trace

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

# **
# ** Template starts here
# **

DEVISE_ROUTES = <<-ROUTES.freeze
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
ROUTES

USE_TURBO_FOR_DEVISE = <<-SOURCE.freeze
  # devise views don't currently work with turbo
  def turbo_for_devise?
    false
  end
SOURCE

ES_BUILD_COMMANDS = <<-SOURCE.freeze
    "show_esbuild" : "bin/rails esbuild:show",
    "kill_esbuild" : "bin/rails esbuild:kill",
SOURCE

# Create a standard devise install with everything enabled
# Add additional attributes username:string and role:string
# NOTE: initial source https://railsbytes.com/public/templates/X8Bsjx
def add_devise
  # see https://stackoverflow.com/a/69748177/960184
  gem 'devise', git: 'https://github.com/heartcombo/devise', branch: 'main'

  # waiting for fix on devise release, use main branch in the meantime
  # gem 'devise'

  #run "bundle add devise"
  do_bundle

  # NOTE: using rails_command isn't needed
  generate "devise:install"

  model_name = ask("What do you want to call your Devise model [user] ?")
  model_name = "user" if model_name.blank?
  attributes = "role:string"
  if yes?("Do you want to any extra attributes to #{model_name} (default:#{attributes})? [y/N]")
    attributes = ask("What attributes?")
  end

  # TODO: Note, check why on railsbytes there is this note about installing devise
  # We don't use rails_command here to avoid accidentally having RAILS_ENV=development as an attribute.
  # not sure I understand why this is done this way, got this from studying a railsbytes comment
  # run "rails generate devise #{model_name} #{attributes}"

  generate "devise", model_name, attributes

  # not using standard default devise views created by generate "devise:views"
  # instead use tailwind modified devise views
  copy_devise_views

  update_devise_db_migration

  insert_into_file('config/routes.rb', after: "devise_for :users\n") do
    DEVISE_ROUTES
  end

  insert_into_file('app/helpers/application_helper.rb', after: "module ApplicationHelper\n") do
    USE_TURBO_FOR_DEVISE
  end
end

def update_devise_db_migration
  devise_migration_filename = Dir.glob('db/migrate/*_devise_create_users.rb').first
  gsub_file devise_migration_filename, '# t.', 't.'
  gsub_file devise_migration_filename, '# add_index :', 'add_index :'
end

# tailwind updated devise views
def copy_devise_views
  devise_views_dir = 'app/views/devise'
  run "rm -fr #{devise_views_dir}"
  directory AddonHelpers.source_dir(devise_views_dir), devise_views_dir
end

# load the utility functions needed for automatically downloading template from repo if needed
repo_require('https://raw.githubusercontent.com/rlogwood/rails_addons/main',
             'lib/config_paths.rb', '..')

repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)
puts "Template directory is #{template_dir}"
add_devise
