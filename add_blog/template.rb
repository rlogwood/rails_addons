def create_resume_scaffold(options)
  generate :scaffold, "post title body:text published:boolean user:references", options
end

def add_blog_to_pages_controller
  template_filename = 'files/controllers/pages_controller.rb'
  app_filename = 'app/controllers/pages_controller.rb'

  if File.exists?(app_filename)
    insert_into_file(app_filename, before: '^end') { "  " }
  else
    copy_file(template_filename, app_filename)
  end
end

def add_html_pipeline_gems
  gem "html-pipeline", "~> 2.14"
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
end

def add_blog_files
  copy_file('files/helpers/blog_helper.rb', 'app/helpers/blog_helper.rb')
  copy_file('files/views/blog.html.erb', 'app/views/pages/blog_helper.rb')
end

def blog_view

end