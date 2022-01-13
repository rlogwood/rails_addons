#!/usr/bin/env ruby
# frozen_string_literal: true

def sys(cmd, *args, **kwargs)
  puts("\n*** running: \e[1m\e[33m#{cmd} #{args}\e[0m\e[22m\n\n")
  system(cmd, *args, exception: true, **kwargs)
  #return $?.exitstatus
  $?.success?
end

def create_rails_7_app_with_tailwind(app_name)
  template_file='~/src/repos/public/rails_addons/use_rails_main/template.rb'
  sys("rails new #{app_name} -T -m #{template_file} -j esbuild --css tailwind --database postgresql")
end

def apply_templates(template_dir, app_name)

  templates = %w[rails7_tailwind_config
                 add_tailwind_scaffold
                 add_devise
                 add_pages_devise_nav
                 add_cancancan
                 add_blog
                 add_error_pages
                ]

  template_error = false
  templates.each do |name|
    template_file = File.join(template_dir, name,'template.rb')
    cmd = "bin/rails app:template LOCATION=\"#{template_file}\" --trace"

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

def create_admin_user(template_dir)
  create_admin_user_script = File.join(template_dir, 'bin', 'create_admin_user.rb')
  sys("bin/rails runner #{create_admin_user_script}")
end

def update_git_ignore
  rules = <<-STRING
# ignore jetbrains IDE files
.idea/

# ignore emacs backup files
*~

# ignore chruby version files
.ruby-version
STRING

  open('.gitignore', 'a') { |f|
    f << rules
  }
end

def perform_initial_commit
  sys('git add .')
  sys('git commit -m "initial version create_rails_app.rb"')
end

def create_app
  template_dir = File.expand_path(File.join(File.dirname(__FILE__),'..'))
  puts "template_dir:(#{template_dir})"
  print "Enter your app name: "
  app_name = gets.chomp
  create_rails_7_app_with_tailwind(app_name)

  Dir.chdir(File.join(Dir.pwd,app_name))
  apply_templates(template_dir, app_name)
  create_admin_user(template_dir)
  perform_initial_commit
end

create_app
update_git_ignore
perform_initial_commit
