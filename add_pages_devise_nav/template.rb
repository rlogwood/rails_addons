# frozen_string_literal: true
# frozen_string_literal: true

# Running locally example:
# template="~/src/repos/public/rails_addons/add_pages_devise_nav/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/add_pages_devise_nav/template.rb"

# Apply the template
# bin/rails app:template LOCATION=$template --trace

# bin/rails app:template LOCATION=~/src/repos/public/rails_addons/add_pages_devise_nav/template.rb --trace

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


def add_navbar
  files_to_copy = ['app/views/shared/_navigation.html.erb',
                   'app/views/shared/_flash_messages.html.erb',
                   'app/javascript/controllers/navigation_controller.js']

  files_to_copy.each do |filename|
    copy_file(File.join('files', filename), filename)
  end

  gsub_file 'app/views/layouts/application.html.erb', '    <%= yield %>', navigation_and_errors_layout
end

def add_basic_pages
  generate 'controller', "pages home about services"
  route "root to: 'pages#home'"
end

def navigation_and_errors_layout
  <<-'END_STRING'
    <%= render partial: 'shared/navigation' %>
    <%= render partial: 'shared/flash_messages' %>
    <div class="container mx-auto px-4">
      <%= yield %>
    </div>
  END_STRING
end

repo_require('https://raw.githubusercontent.com/rlogwood/rails_addons/main',
             'lib/config_paths.rb', '..')

repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)
puts "Template directory is #{template_dir}"
add_basic_pages
add_navbar
