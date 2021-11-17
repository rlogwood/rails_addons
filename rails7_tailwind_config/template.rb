# frozen_string_literal: true
# Running locally example:
# template="~/src/repos/public/rails_addons/rails7_tailwind_config/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/active_storage_test/template.rb"

# Apply the template
# bin/rails app:template LOCATION=$template --trace


## Boilerplate starts
## ** Include this boilerplate in every template that you want to source from github
## ** It can't be required since the repo will be cloned by it
## code for checking out template from repo if needed
## see other usage examples:
## https://raw.githubusercontent.com/excid3/jumpstart/master/template.rb
## https://github.com/mattbrictson/rails-template

# clone_repo and check out branched referenced by template_filename
def clone_repo(template_filename, repo_path)
  require "tmpdir"

  repo_name = File.basename(repo_path,'.git')
  addon_name = File.dirname(template_filename).split('/')[-1]
  branch_name = template_filename[%r{#{repo_name}/(.+)/#{addon_name}/template.rb}, 1]
  puts "branch_name:(#{branch_name})"

  tempdir = Dir.mktmpdir("#{repo_name}-")
  puts "*** tempdir: (#{tempdir})"

  at_exit { FileUtils.remove_entry(tempdir) }

  git clone: [
    "--quiet",
    repo_path,
    tempdir
  ].map(&:shellescape).join(" ")

  unless branch_name.nil?
    Dir.chdir(tempdir) do
      git checkout: branch_name
    end
  end

  # template_dir
  File.join(tempdir, addon_name)
end

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path(template_filename, repo_path)
  template_dir =
    if template_filename =~ %r{\Ahttps?://}
      clone_repo(template_filename, repo_path)
    else
      File.dirname(template_filename)
    end

  source_paths.unshift(template_dir)
  puts "*** source_paths: (#{source_paths.join(' ')})"
  puts "*** template_dir: (#{template_dir})"
  template_dir
end

##
## Boilerplate ends
##

#"build:css": "tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css"
def update_files
  # use postcss
  gsub_file 'package.json', 'build:css": "tailwindcss -i', 'build:css": "tailwindcss --postcss -i'
end

def copy_files
  # postcss config
  copy_file('files/postcss.config.js', 'postcss.config.js')
end

def add_packages
  # add packages needed for rails js and postcss import
  packages = %w[@rails/request.js postcss-import postcss-nesting postcss-simple-vars]
  packages.each { |package| run "yarn add #{package}" }
end

SAFE_DIRNAME = "safe_#{Time.new.strftime("%Y-%m-%d_%H:%M:%S_%L")}"

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

def add_basic_landing_page
  generate(:controller, 'tailwind_test', 'index')
  copy_file('files/app/views/tailwind_test/index.html.erb', 'app/views/tailwind_test/index.html.erb',
            { force: true })
  #/home/dever/src/repos/public/rails_addons/rails7_tailwind_config/files/app/stylesheets/application.tailwind.css
  copy_new_file('app/assets/stylesheets/application.tailwind.css')
  copy_new_dir('app/assets/stylesheets/examples')
  route "root to: 'tailwind_test#index'"
end

def add_rails7_tailwind_config
  copy_files
  update_files
  add_packages
  add_basic_landing_page
end

repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)

puts "template_dir:#{template_dir}"
add_rails7_tailwind_config


