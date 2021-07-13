# frozen_string_literal: true

# Utilities that can be used in any template
# Place your template.rb in a subdirectory named for the add-on
# Add the following to the topy of your template.rb
# require_relative '../lib/template_helpers'
# initialize_template_helpers(__FILE__)

# custom exception for any template error
class TemplateError < StandardError
  def initialize(message)
    # make the message standout with some newlines and asterisks
    super("\n***\n*** #{message}\n***\n")
  end
end

# use constants for the webpacker 5 and 6 pack locations
# see https://github.com/rails/webpacker/blob/master/docs/v6_upgrade.md
WEBPACKER_5_PACKS_ENTRYPOINT = 'app/javascript/packs'
WEBPACKER_6_PACKS_ENTRYPOINT = 'app/packs/entrypoints'

# webpacker javascript pack file name
APPLICATION_JS_FILENAME = 'application.js'

# location of rails template currently being evaluated
@template_dirname = nil

# full path of local webpacker 5 javascript pack file
@webpacker_5_application_js = nil

# full path of local webpacker 6 javascript pack file
@webpacker_6_application_js = nil

# initialize local locations for currently template evaluation
def initialize_template_helpers(template_file)
  @template_dirname = File.dirname(template_file)
  @webpacker_5_application_js = File.join(destination_root, WEBPACKER_5_PACKS_ENTRYPOINT, APPLICATION_JS_FILENAME)
  @webpacker_6_application_js = File.join(destination_root, WEBPACKER_6_PACKS_ENTRYPOINT, APPLICATION_JS_FILENAME)
  source_paths.unshift(template_dirname)
end

# directory where current template is located
def template_dirname
  @template_dirname
end

# by convention all template files will be located under the 'files' directory
def template_relative_filename(file)
  File.join('files', file)
end

# return full template filename, assumes file located in subdirectory files of template location
# raises error if file not found
def template_full_filename(file)
  filename = File.join(template_dirname, template_relative_filename(file))
  raise TemplateError, "Template full filename (#{filename}) not found!" unless File.exists?(filename)

  filename
end

# Custom bundle command ensures dependencies are correctly installed
def do_bundle
  Bundler.with_unbundled_env { run "bundle install" }
end

# current app users webpacker 5 if of javascript pack for webpacker 5 exists
def webpacker_5_app?
  File.exist?(@webpacker_5_application_js)
end

# current app users webpacker 6 if of javascript pack for webpacker 6 exists
def webpacker_6_app?
  File.exist?(@webpacker_6_application_js)
end

# packs location for current apps webpacker version
def webpacker_packs_entrypoint
  return WEBPACKER_5_PACKS_ENTRYPOINT if webpacker_5_app?
  return WEBPACKER_6_PACKS_ENTRYPOINT if webpacker_6_app?

  raise TemplateError, "Only Webpacker 5 and 6 suppored"
end

# search for a file staring from the root_dir and checking each subdirectory listed in parent_dirs,
# for any filename listed in filenames
def find_first_filename_match(file_purpose, root_dir, parent_dirs, filenames)
  parent_dirs.each do |dirname|
    filenames.each do |filename|
      filename = File.join(root_dir, dirname, filename)
      return filename if File.exists?(filename)
    end
  end

  raise TemplateError, "No existing file found in root (#{root_dir}) for (#{file_purpose}) file"\
  "Searched: Directories:(#{parent_dirs.join(', ')}) for any of the files:(#{filenames.join(', ')})"
end

# return location of asset pipeline stylesheet
def asset_pipeline_stylesheet
  find_first_filename_match('application top-level stylesheet', destination_root,
                            ['app/assets/stylesheets'],
                            %w[application.css application.scss])
end

# return location of asset webpacker stylesheet pack
def webpacker_application_stylesheet
  find_first_filename_match('application top-level stylesheet', destination_root,
                            [webpacker_packs_entrypoint],
                            %w[application.css application.scss])
end

# use existance of top level application stylesheet as proxy to determine if app uses asset pipeline for css
def asset_pipeline_app?
  webpacker_application_stylesheet
  false
rescue TemplateError
  asset_pipeline_stylesheet
  true
end

# location to copy additional stylesheets defined in the template
def additional_stylesheets_dir
  stylesheet_filename = application_stylesheet_filename
  dirname = if asset_pipeline_app?
              File.dirname(stylesheet_filename)
            else
              File.expand_path(File.join(File.dirname(stylesheet_filename),'..', 'stylesheets'))
            end
  puts "additional stylesheets directory: (#{dirname})"
  dirname
end

# name of webpacker javascript pack file
def application_js_filename_for_webpacker
  if webpacker_5_app?
    @webpacker_5_application_js
  elsif webpacker_6_app?
    @webpacker_6_application_js
  else
    raise TemplateError, 'Unreconized Webpacker configuration, could not find application.js for Webpacke5 or 6. '\
    "Checked Ver5:(#{@webpacker_5_application_js}) Ver6:(#{@webpacker_6_application_js})"
  end
end

# name of top level application stylesheet
def application_stylesheet_filename
  begin
    return webpacker_application_stylesheet
  rescue TemplateError
    return asset_pipeline_stylesheet
  end

  raise TemplateError, "Can't find application stylesheet filename"
end

# location to copy additional javascript files defined in the template
def webpacker_javascript_files_dir
  File.expand_path(File.join(webpacker_packs_entrypoint,'..', 'src'))
end

# return true if filename contains the specified regex, false otherwise
def file_has_string(filename, regex)
  found = []
  File.open(filename) { |f| found = f.grep(regex) }
  !found.empty?
end

# NOTES:
# TODO: evaluate using find_in_source_paths?
# file = 'javascript/direct_uploads.js'
# fname = find_in_source_paths(template_relative_filename(file))
# puts "fname=(#{fname})"
# ==> fname=(/home/dever/src/repos/rails_addons/active_storage_test/files/javascript/direct_uploads.js)
#
# TODO determine the purpose of relative_to_original_destination_root
# Unable to get this method to do anything useful
# # puts "destination_root = (#{destination_root})"
# fname = relative_to_original_destination_root("./job.rb")
# puts "fname=(#{fname})"
#
# fname = relative_to_original_destination_root("./app/views/jobs/_form.html.erb")
# puts "fname=(#{fname})"