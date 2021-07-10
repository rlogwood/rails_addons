def do_bundle
  # Custom bundle command ensures dependencies are correctly installed
  Bundler.with_unbundled_env { run "bundle install" }
end

def install_active_storage
  rails_command "active_storage:install"
end

def create_posts_scaffold_example(template_dir)
  rails_command "destroy scaffold post"
  generate(:scaffold, 'post', 'title:string', 'body:text')
  insert_into_file('app/models/post.rb', before: /^end/) { "\nhas_many_attached :files\n" }

  form_addition_filename = File.join(template_dir, 'files/views/_form_addition.html.erb')
  show_addition_filename = File.join(template_dir, 'files/views/show_addition.html.erb')

  insert_into_file('app/views/posts/_form.html.erb',
                   after: %r{<%= form.text_field :title %>\n *</div>\n}m) { File.read(form_addition_filename) }

  insert_into_file('app/views/posts/show.html.erb',
                   after: %r{<strong>Body:</strong>.*<%= @post.body %>\n *</p>\n}m) { File.read(show_addition_filename) }

end

def update_storage_yml(template_dir)
  storage_additions_filename = File.join(template_dir, 'files/lib/active_storage_config/storage_additions.yml')
  raise("Storage config not found (#{storage_additions_filename})") unless File.exist? storage_additions_filename

  append_to_file('config/storage.yml') { File.read(storage_additions_filename)}
end

def update_post_controller_params
  new_post_params = <<~END_STRING
      def post_params
        params.require(:post).permit(:title, :body, files: [])
      end
    end
  END_STRING

  gsub_file('app/controllers/posts_controller.rb', / *def post_params\n.*\n *end\n/m, new_post_params)
end

def update_application_js(template_dir)
  application_js_filename = 'app/javascript/packs/application.js'

  raise "Only supporting Webpacker 5 - Missing #{application_js_filename}" unless File.exist?(application_js_filename)

  append_to_file(application_js_filename, 'import "../src/direct_uploads"')

  copy_file('files/javascript/direct_uploads.js', 'app/javascript/src/direct_uploads.js', force: true)
end

def update_css(template_dir)
  copy_file('files/stylesheets/direct_uploads.css','app/assets/stylesheets/direct_uploads.css')
end

def copy_cors_config
  copy_file('files/lib/active_storage_config/digital_ocean/cors.xml',
            'lib/active_storage_config/digital_ocean/cors.xml', force: true)
end

def update_production_environment
  # use digital ocean spaces in prodution
  active_storage_service = 'config.active_storage.service = :spaces'
  gsub_file('config/environments/production.rb', /config.active_storage.service = :local/, active_storage_service)
end

def update_root_route
  route "root to: 'posts#index'"
end

def update_gitignore
  append_to_file('.gitignore', "\n.idea\n.ruby-version\n*~\n")
end

def copy_procfile
  copy_file('files/Procfile', 'Procfile')
end

def update_gemfile
  gem 'aws-sdk-s3'
  do_bundle
end

def add_active_storage
  template_dir = File.dirname(__FILE__)
  source_paths.unshift(template_dir)
  install_active_storage
  create_posts_scaffold_example(template_dir)
  update_storage_yml(template_dir)
  update_post_controller_params
  update_application_js(template_dir)
  update_css(template_dir)
  update_root_route
  update_production_environment
  copy_cors_config
  update_gitignore
  copy_procfile
  update_gemfile
end

puts("Create active storage example with asset pipeline css and webpacker js")
add_active_storage
