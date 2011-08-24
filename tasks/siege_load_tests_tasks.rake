namespace :siege_load_tests do

 desc "Install assets"
  task :install_assets do
    FileUtils.cp_r File.join(Rails.root.to_s, "/vendor/plugins/siege_load_test/public"), File.join(Rails.root.to_s, "/public/testing/assets")
  end

end