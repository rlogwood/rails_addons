# frozen_string_literal: true

require_relative '../lib/config_paths'

# Running locally example:
# template="~/src/repos/public/rails_addons/rails7_tailwind_config/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/active_storage_test/template.rb"

# Apply the template
# bin/rails app:template LOCATION=$template --trace

repo_path = 'https://github.com/rlogwood/rails_addons.git'
addon_name = 'rails7_tailwind_config'
branch_name_regex = %r{rails_addons/(.+)/#{addon_name}/template.rb}

template_dir = add_template_repository_to_source_path(__FILE__, repo_path, branch_name_regex)

puts "template_dir:#{template_dir}"

# Running locally example:
# template="~/src/repos/public/rails_addons/rails7_tailwind_config/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/active_storage_test/template.rb"

# Apply the template
# bin/rails app:template LOCATION=$template --trace
