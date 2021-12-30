# frozen_string_literal: true

# After require file, include into template.rb as follows.
# This is done so that thor commands like 'run' will be evaluated in the right context
# class << self
#   include ThorAddons
# end

module ThorAddons
  def do_bundle
    Bundler.with_unbundled_env { run "bundle install" }
  end
end

