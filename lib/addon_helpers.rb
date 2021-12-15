module AddonHelpers
  # template source files are all relative to 'files' directory
  def self.source_dir(dirname)
    File.join('files',dirname)
  end
end
