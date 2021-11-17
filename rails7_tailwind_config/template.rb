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
  branch_name_regex = %r{#{repo_name}/(.+)/#{addon_name}/template.rb}
  branch_name = template_filename[branch_name_regex(repo_name, addon_name), 1]
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


repo_path = 'https://github.com/rlogwood/rails_addons.git'
template_dir = add_template_repository_to_source_path(__FILE__, repo_path)

puts "template_dir:#{template_dir}"
