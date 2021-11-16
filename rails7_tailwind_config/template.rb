# frozen_string_literal: true

# Running locally example:
# template="~/src/repos/public/rails_addons/rails7_tailwind_config/template.rb"

# Running remotely:
# template="https://raw.githubusercontent.com/rlogwood/rails_addons/main/active_storage_test/template.rb"

# Apply the template
# bin/rails app:template LOCATION=$template --trace


# when loading from repo, unable to require_relative '../lib/config_paths'
def clone_repo(template_filename, repo_path, branch_name_regex)
  require "tmpdir"
  tempdir = Dir.mktmpdir("rails_templates-")
  puts "*** tempdir: (#{tempdir})"

  at_exit { FileUtils.remove_entry(tempdir) }

  git clone: [
    "--quiet",
    repo_path,
    tempdir
  ].map(&:shellescape).join(" ")

  if (branch = template_filename[branch_name_regex, 1])
    Dir.chdir(tempdir) do
      git checkout: branch
    end
  end

  # template_dir
  File.join(tempdir,"tailwindcss_app")
end

# Copied from: https://raw.githubusercontent.com/excid3/jumpstart/master/template.rb
# which it copied it from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path(template_filename, repo_path, branch_name_regex)
  template_dir =
    if __FILE__ =~ %r{\Ahttps?://}
      clone_repo(template_filename, repo_path, branch_name_regex)
    else
      File.dirname(template_filename)
    end

  source_paths.unshift(template_dir)
  puts "*** source_paths: (#{source_paths.join(' ')})"
  puts "*** template_dir: (#{template_dir})"
  template_dir
end



repo_path = 'https://github.com/rlogwood/rails_addons.git'
addon_name = 'rails7_tailwind_config'
branch_name_regex = %r{rails_addons/(.+)/#{addon_name}/template.rb}

template_dir = add_template_repository_to_source_path(__FILE__, repo_path, branch_name_regex)

puts "template_dir:#{template_dir}"

