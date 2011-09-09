require File.join(Rails.root.to_s, "/vendor/plugins/siege_load_test/lib/siege_load_test.rb")
puts "** Installing Siege Load Test plugin..."
FileUtils.mkdir_p File.join(Rails.root.to_s, File.dirname("/public/testing/siege_load_test/assets"))
FileUtils.cp_r File.join(Rails.root.to_s, "/vendor/plugins/siege_load_test/public"), File.join(Rails.root.to_s, "/public/testing/siege_load_test/assets")
FileUtils.rm_rf(File.join(Rails.root.to_s, "/vendor/plugins/siege_load_test/public"))
SiegeLoadTest.generate_token
puts "** Successfully installed Siege Load Test plugin..."
