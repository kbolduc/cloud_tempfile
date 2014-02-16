namespace :cloud_tempfile do
  desc "Clean up expired temp files from the remote storage"
  task :clear => :environment do
    CloudTempfile.clear
  end
end

