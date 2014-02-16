# cloud_tempfile/engine.rb
#
# Author::    Kevin Bolduc
# Date::      14-02-24
# Time::      3:23 PM

module CloudTempfile
  class Engine < Rails::Engine

    engine_name "cloud_tempfile"

    initializer "cloud_tempfile config", :group => :all do |app|
      app_initializer = Rails.root.join('config', 'initializers', 'cloud_tempfile.rb').to_s
      app_yaml = Rails.root.join('config', 'cloud_tempfile.yml').to_s

      if File.exists?( app_initializer )
        CloudTempfile.log "CloudTempfile: using #{app_initializer}"
        load app_initializer
      elsif !File.exists?( app_initializer ) && !File.exists?( app_yaml )
        CloudTempfile.log "CloudTempfile: using default configuration from built-in initializer"
        CloudTempfile.configure do |config|
          config.fog_provider = ENV['FOG_PROVIDER'] if ENV.has_key?('FOG_PROVIDER')
          config.fog_directory = ENV['FOG_DIRECTORY'] if ENV.has_key?('FOG_DIRECTORY')
          config.fog_region = ENV['FOG_REGION'] if ENV.has_key?('FOG_REGION')

          config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID'] if ENV.has_key?('AWS_ACCESS_KEY_ID')
          config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY'] if ENV.has_key?('AWS_SECRET_ACCESS_KEY')
          config.aws_reduced_redundancy = ENV['AWS_REDUCED_REDUNDANCY'] == true  if ENV.has_key?('AWS_REDUCED_REDUNDANCY')

          config.rackspace_username = ENV['RACKSPACE_USERNAME'] if ENV.has_key?('RACKSPACE_USERNAME')
          config.rackspace_api_key = ENV['RACKSPACE_API_KEY'] if ENV.has_key?('RACKSPACE_API_KEY')

          config.google_storage_access_key_id = ENV['GOOGLE_STORAGE_ACCESS_KEY_ID'] if ENV.has_key?('GOOGLE_STORAGE_ACCESS_KEY_ID')
          config.google_storage_secret_access_key = ENV['GOOGLE_STORAGE_SECRET_ACCESS_KEY'] if ENV.has_key?('GOOGLE_STORAGE_SECRET_ACCESS_KEY')

          config.enabled = (ENV['CLOUD_TEMPFILE_ENABLED'] == 'true') if ENV.has_key?('CLOUD_TEMPFILE_ENABLED')
          config.public = (ENV['CLOUD_TEMPFILE_PUBLIC'] == 'true') if ENV.has_key?('CLOUD_TEMPFILE_PUBLIC')
          config.public_path = ENV['CLOUD_TEMPFILE_PUBLIC_PATH'] if ENV.has_key?('CLOUD_TEMPFILE_PUBLIC_PATH')
          config.expiry = ENV['CLOUD_TEMPFILE_EXPIRY'] if ENV.has_key?('CLOUD_TEMPFILE_EXPIRY')

          config.clean_up = (ENV['CLOUD_TEMPFILE_CLEAN_UP'] == 'true') if ENV.has_key?('CLOUD_TEMPFILE_CLEAN_UP')
          config.clean_up_older_than = ENV['CLOUD_TEMPFILE_CLEAN_UP_OLDER_THAN'] if ENV.has_key?('CLOUD_TEMPFILE_CLEAN_UP_OLDER_THAN')
        end

        config.prefix = ENV['CLOUD_TEMPFILE_PREFIX'] if ENV.has_key?('CLOUD_TEMPFILE_PREFIX')
      end

      if File.exists?( app_yaml )
        CloudTempfile.log "CloudTempfile: YAML file found #{app_yaml} settings will be merged into the configuration"
      end
    end
  end
end