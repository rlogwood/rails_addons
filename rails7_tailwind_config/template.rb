# frozen_string_literal: true
# Running locally example:
# template="~/src/repos/public/rails_addons/rails7_tailwind_config/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/active_storage_test/template.rb"

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

def update_files
  # use postcss in tailwind build, add --postcss option
  gsub_file 'package.json', 'build:css": "tailwindcss -i', 'build:css": "tailwindcss --postcss -i'
end

def copy_files
  # basic postcss config
  copy_file('files/postcss.config.js', 'postcss.config.js')
end

def add_packages
  # add packages needed for rails js and postcss import
  packages = %w[@rails/request.js tailwindcss@latest postcss-import postcss-nesting postcss-simple-vars autoprefixer]
  packages.each { |package| run "yarn add #{package}" }
end

SAFE_DIRNAME = "safe_#{Time.new.strftime('%Y-%m-%d_%H:%M:%S_%L')}".freeze

def save_original_file(filename)
  safe_dir = File.join(File.dirname(filename),SAFE_DIRNAME)
  Dir.mkdir safe_dir unless Dir.exist?(safe_dir)
  run "mv #{filename} #{safe_dir}"
end

def copy_new_file(filename)
  save_original_file(filename)
  copy_file(File.join('files', filename), filename)
end

def copy_new_dir(dirname)
  directory(File.join('files', dirname), dirname)
end

def add_build_management_commands
  copy_new_dir('lib/tasks')
  insert_into_file('package.json', after: "\"scripts\": {\n") do
    <<-COMMANDS
    "show_esbuild" : "bin/rails esbuild:show",
    "kill_esbuild" : "bin/rails esbuild:kill",
    COMMANDS
  end
end

def add_test_tailwind_landing_page
  generate(:controller, 'tailwind_test', 'index')
  copy_file('files/app/views/tailwind_test/index.html.erb', 'app/views/tailwind_test/index.html.erb',
            { force: true })
  copy_new_file('app/assets/stylesheets/application.tailwind.css')
  copy_new_dir('app/assets/stylesheets/examples')
end

def user_instructions
  <<-INSTRUCTIONS
  ***
  *** After restarting your app
  *** Please Visit "tailwind_test/index" to confirm tailwindcss is working
  *** For example http://localhost:3000/tailwind_test/index
  ***
  INSTRUCTIONS
end

def add_rails7_tailwind_config
  copy_files
  update_files
  add_packages
  add_test_tailwind_landing_page
  add_build_management_commands
  puts user_instructions
end

repo_require('https://raw.githubusercontent.com/rlogwood/rails_addons/main',
             'lib/config_paths.rb', '..')

repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)
puts "Template directory is #{template_dir}"
add_rails7_tailwind_config
