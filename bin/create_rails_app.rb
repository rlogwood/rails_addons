#!/usr/bin/env ruby
# frozen_string_literal: true

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


def sys(cmd, *args, **kwargs)
  puts("\n*** running: \e[1m\e[33m#{cmd} #{args}\e[0m\e[22m\n\n")
  system(cmd, *args, exception: true, **kwargs)
  #return $?.exitstatus
  $?.success?
end

def create_rails_7_app_with_tailwind(app_name)
  template_file='~/src/repos/public/rails_addons/use_rails_main/template.rb'
  sys("rails new #{app_name} -m #{template_file} -j esbuild --css tailwind --database postgresql")
end

def apply_templates(app_name, location)

  templates = %w[rails7_tailwind_config
                 add_tailwind_scaffold
                 add_devise
                 add_pages_devise_nav
                 add_cancancan
                 add_blog
                ]

  template_error = false
  templates.each do |name|
    cmd = "bin/rails app:template LOCATION=\"#{location}/#{name}/template.rb\" --trace"
    unless sys(cmd)
      puts "\n** ERROR in template (#{name})"
      template_err = true
      break
    end
  end

  # note: db:reset fails if database migrate hasn't run
  #sys('bin/rails db:drop')
  #sys('bin/rails db:create')
  #sys('bin/rails db:migrate')
  sys('bin/rails db:prepare')
end

def create_admin_user
  create_admin_user_script = 'create_admin_user.rb'
  sys('bin/rails runner #{create_admin_user_script}')
end

print "Enter your app name: "
app_name = gets.chomp

# create_rails_7_app_with_tailwind(app_name)

location='~/src/repos/public/rails_addons'
Dir.chdir(File.join(Dir.pwd,app_name))

# apply_templates(app_name)

create_admin_user

