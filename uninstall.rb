puts "** Uninstalling Siege Load Test plugin...."
FileUtils.rmdir(File.join(Rails.root.to_s, "/public/testing"), :noop => true)
