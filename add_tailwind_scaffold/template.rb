# frozen_string_literal: true
require_relative '../lib/addon_helpers'

# Running locally example:
# template="~/src/repos/public/rails_addons/add_tailwind_scaffold/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/add_tailwind_scaffold/template.rb"

# Apply the template
# bin/rails app:template LOCATION=$template --trace

# bin/rails app:template LOCATION=~/src/repos/public/rails_addons/add_tailwind_scaffold/template.rb --trace
# bin/rails app:template LOCATION=https://raw.githubusercontent.com/rlogwood/rails_addons/main/add_tailwind_scaffold/template.rb --trace

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

# NOTE: Thor directory command tries to evaluate templates (files ending in .tt)
# so we hae to have our own copy command
def copy_dir(source_dir, destination_dir)
  copy_target_dir = File.join(destination_dir,"..")
  commands = [
    "rm -fr #{destination_dir}",
    "mkdir  -p #{destination_dir}",
    "cp -pfR #{source_dir} #{copy_target_dir}"
  ]

  commands.each do |cmd|
    next if AddonHelpers.sys(cmd)

    puts "\n** ERROR running command:\n** #{cmd}\n** \n"
    return false
  end

  true
end

# def test_copy_dir(source_dir, destination_dir)
#   directory source_dir, destination_dir
# end
# def copy_template_files(template_dir)
#   # add tailwind scaffolding templates
#   source_dir = File.join(template_dir,'files', 'lib', 'templates')
#   destination_dir = File.join('lib','templates')
#   # NOTE: Thor directory command tries to evaluate templates (files ending in .tt)
#   # so we hae to have our own copy command
#   copy_dir(source_dir, destination_dir)
# end
#
# def copy_dir(source_dir, destination_dir)
#   run "rm -fr #{destination_dir}"
#   run "mkdir  -p #{destination_dir}"
#   copy_target_dir = File.join(destination_dir,"..")
#   run "cp -pfR #{source_dir} #{copy_target_dir}"
# end

# error messages partial used for templates
def copy_error_message_partial
  filename = 'app/views/application/_error_messages.html.erb'

  copy_file(AddonHelpers.source_location(filename), filename, force: true)
end

def copy_template_files(template_dir)
  # add tailwind scaffolding templates
  scaffold_templates_dir = 'lib/templates/erb'
  source_dir = File.join(template_dir, AddonHelpers.source_location(scaffold_templates_dir))
  #no_eval_copy_dir(AddonHelpers.source_dir(templates_dir), templates_dir)
  #directory AddonHelpers.source_location(templates_dir), templates_dir
  copy_dir(source_dir, scaffold_templates_dir)
end

repo_require('https://raw.githubusercontent.com/rlogwood/rails_addons/main',
             'lib/config_paths.rb', '..')

repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)
puts "Template directory is #{template_dir}"
copy_template_files(template_dir)
copy_error_message_partial
