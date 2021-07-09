# frozen_string_literal: true

def do_bundle
  # Custom bundle command ensures dependencies are correctly installed
  Bundler.with_unbundled_env { run "bundle install" }
end

def update_navigation
  update = <<-END_STRING
      <%= link_to 'Blog', pages_blog_path, class: "nav-link" %>
      <%= link_to 'Posts', posts_path, class: "nav-link"  if can? :manage, Post %>
  END_STRING

  before_regex = %r{ *</div>\n *<div class="text-sm md:flex-grow">\n *<% if user_signed_in\? %>}m
  app_filename = "app/views/shared/_navigation.html.erb"
  raise("Missing navigation partial: (#{app_filename}") unless File.exists?(app_filename)

  insert_into_file(app_filename, before: before_regex) { update }
end

def update_routes
  app_filename = "config/routes.rb"
  insert_into_file(app_filename, before: /^end/) { "\n  get 'pages/blog'\n" }
end

def remove_post_scaffold(perform_rollback)
  rails_command 'db:rollback STEP=1' if perform_rollback
  rails_command "destroy scaffold post"
end

def create_post_scaffold(options)
  generate :scaffold, 'post title body:text published:boolean publish_date:datetime user:references', options
end

def append_before_end_or_create_file(replacement_filename, app_filename, update)
  if File.exists?(app_filename)
    insert_into_file(app_filename, before: /^end/) { update }
  else
    copy_file(replacement_filename, app_filename, force: true)
  end
end

def add_published_scope_to_posts
  app_filename = 'app/models/post.rb'
  update = "\n  scope :published_posts, -> { where(published: true) }\n\n"
  insert_into_file(app_filename, before: /^end/) { update }
end

def update_cancancan_abilities(template_dir)
  abilities_flname = File.join(template_dir,'files/models/fragments/ability.rb')
  cancan_abilities_to_add = File.read(abilities_flname)
  app_filename = 'app/models/ability.rb'
  raise("Missing cancan ability file: #{app_filename}") unless File.exists?(app_filename)

  insert_into_file(app_filename, before: /  end\n^end/m) { cancan_abilities_to_add }
end

def update_user_for_cancan_abilities_and_posts(template_dir)
  user_flname = File.join(template_dir,'files/models/fragments/user.rb')
  user_additions = File.read(user_flname)
  app_filename = 'app/models/user.rb'
  raise("Missing user model file: #{app_filename}") unless File.exists?(app_filename)

  insert_into_file(app_filename, before: /^end/) { user_additions }
end


def add_blog_to_pages_controller
  replacement_filename = 'files/controllers/pages_controller.rb'
  app_filename = 'app/controllers/pages_controller.rb'
  update = "\n  def blog; end\n\n"
  append_before_end_or_create_file(replacement_filename, app_filename, update)
end

def add_html_pipeline_gems
  html_pipeline_gems = <<~END_STRING

    gem 'html-pipeline', '~> 2.14'
    # html-pipeline dependencies - note, initially used suggested
    # versions from html-pipeline test example, but pushed each
    # dependency to the latest in the process of trying to diagnose
    # markdown filter clobbering result for non-markdown content
    # and everything seems to work OK with these latest versions
    gem 'commonmarker', '~> 0.21.0'     # markdown filter
    gem "escape_utils", "~> 1.2"        # plain text filter
    gem 'gemoji', '~> 3.0.1'            # emoji filter
    gem 'rinku', '~> 2.0.6'             # auto-linking
    gem 'rouge', '~> 3.26'              # syntax highlighting filter
    gem 'sanitize','~> 5.2.3'           # sanitization filter

  END_STRING

  append_to_file('Gemfile', html_pipeline_gems)
  do_bundle
end

def add_blog_files
  copy_file('files/helpers/blog_helper.rb', 'app/helpers/blog_helper.rb')
  copy_file('files/views/blog.html.erb', 'app/views/pages/blog.html.erb')
  copy_file('files/controllers/posts_controller.rb', 'app/controllers/posts_controller.rb', force: true)
  add_blog_to_pages_controller
end

def update_css
  insert_into_file('app/packs/entrypoints/application.scss',
                   after: '@import "../stylesheets/components/forms";') { %(\n@import "../stylesheets/blog";) }
  append_to_file('app/packs/entrypoints/application.js', 'import "../stylesheets/rogue.scss.erb"')
  copy_file('files/packs/stylesheets/blog.scss', 'app/packs/stylesheets/blog.scss', force: true)
  copy_file('files/packs/stylesheets/rogue.scss.erb', 'app/packs/stylesheets/rogue.scss.erb', force: true)
end

def add_blog(options, perform_migration_rollback)
  template_dir = File.dirname(__FILE__)
  source_paths.unshift(template_dir)
  remove_post_scaffold(perform_migration_rollback)
  create_post_scaffold(options)
  add_html_pipeline_gems
  add_blog_files
  add_published_scope_to_posts
  update_cancancan_abilities(template_dir)
  update_routes
  update_navigation
  update_user_for_cancan_abilities_and_posts(template_dir)
  update_css
  rails_command "db:migrate", abort_on_failure: true
end

add_blog("--migration", true)

