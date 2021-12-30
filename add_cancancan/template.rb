# frozen_string_literal: true
require_relative '../lib/addon_helpers'
require_relative '../lib/thor_addons'

#require_relative '../lib/stuff'

# class Thor
#   extend AddonHelpers
# end

class << self
  include ThorAddons
end

# Running locally example:
# template="~/src/repos/public/rails_addons/add_cancancan/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/add_cancancan/template.rb"

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

def add_cancancan
  gem 'cancancan'
  rails_command 'g cancan:ability'
  do_bundle
end

# **
# ** main
# **

# load the utility functions needed for automatically downloading template from repo if needed
repo_require('https://raw.githubusercontent.com/rlogwood/rails_addons/main',
             'lib/config_paths.rb', '..')

repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)
puts "Template directory is #{template_dir}"
add_cancancan

