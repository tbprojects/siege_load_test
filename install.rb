puts "** Installing Siege Load Test plugin..."
FileUtils.mkdir_p(File.dirname("/public/testing/assets"))
FileUtils.cp_r File.join(Rails.root.to_s, "/vendor/plugins/siege_load_test/public"), File.join(Rails.root.to_s, "/public/testing/assets")
puts "** Successfully installed Siege Load Test plugin..."