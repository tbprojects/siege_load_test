puts "** Uninstalling Siege Load Test plugin...."
FileUtils.rm_rf(File.join(Rails.root.to_s, "/public/testing/siege_load_test"))
