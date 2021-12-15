# frozen_string_literal: true

def sys(cmd, *args, **kwargs)
  puts("\n*** running: \e[1m\e[33m#{cmd} #{args}\e[0m\e[22m\n\n")
  system(cmd, *args, exception: true, **kwargs)
  #return $?.exitstatus
  $?.success?
end

def create_rails_7_app_with_tailwind(app_name)
  sys("rails new #{app_name} -j esbuild --css tailwind --database postgresql")
end

def apply_templates(app_name)
  location='~/src/repos/public/rails_addons'

  Dir.chdir(File.join(Dir.pwd,app_name))

  templates = %w[rails7_tailwind_config
                 add_tailwind_scaffold
                 add_devise
                 add_pages_devise_nav]

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
  sys('bin/rails db:drop')
  sys('bin/rails db:create')
  sys('bin/rails db:migrate')
end

print "Enter your app name: "
app_name = gets.chomp
create_rails_7_app_with_tailwind(app_name)
apply_templates(app_name)
