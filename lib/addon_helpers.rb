module AddonHelpers
  # template source files are all relative to 'files' directory
  def self.source_dir(pathname)
    File.join('files',pathname)
  end

  class << self
    alias source_location source_dir
  end

  def self.sys(cmd, *args, **kwargs)
    puts("\n*** running: \e[1m\e[33m#{cmd} #{args}\e[0m\e[22m\n\n")
    system(cmd, *args, exception: true, **kwargs)
    #return $?.exitstatus
    $?.success?
  end
end
