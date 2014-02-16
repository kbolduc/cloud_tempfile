CloudTempfile.configure do |config|
  # Enable or disable the CloudTempfile functionality (Default: true)
  # config.enabled = true
  <%- if aws? -%>
  config.fog_provider = 'AWS'
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  # The name of Amason S3 Bucket
  config.fog_directory = ENV['FOG_DIRECTORY']
  # You may need to specify what region your storage bucket is in. This may increase upload performance by configuring your region
  # config.fog_region = 'eu-west-1'
  # To use AWS reduced redundancy storage.
  # (http://aws.amazon.com/about-aws/whats-new/2010/05/19/announcing-amazon-s3-reduced-redundancy-storage/)
  # config.aws_reduced_redundancy = true
  <%- elsif google? -%>
  config.fog_provider = 'Google'
  config.fog_directory = ENV['FOG_DIRECTORY']
  config.google_storage_access_key_id = ENV['GOOGLE_STORAGE_ACCESS_KEY_ID']
  config.google_storage_secret_access_key = ENV['GOOGLE_STORAGE_SECRET_ACCESS_KEY']
  <%- elsif rackspace? -%>
  config.fog_provider = 'Rackspace'
  config.fog_directory = ENV['FOG_DIRECTORY']
  config.rackspace_username = ENV['RACKSPACE_USERNAME']
  config.rackspace_api_key = ENV['RACKSPACE_API_KEY']
  # if you need to change rackspace_auth_url (e.g. if you need to use Rackspace London)
  # config.rackspace_auth_url = "lon.auth.api.rackspacecloud.com"
  <%- end -%>
  #
  # (String) This is a string file path which will be appended to the filename
  # config.prefix =  "<%= ENV['RAILS_ENV'] %>/tmp/"
  # (Boolean) When true, the file publicly accessible. When false (default), a authenticated url will attempt to be generated
  # config.public = true
  # (Integer) The number of seconds the authenticated url will be valid (600 seconds = 10 minutes)
  # config.expiry = 600
  # (Boolean) When true, the clean up task (CloudTempfile.clear) will be able to run. Perfect for a cron clean up! ;)
  # config.clean_up = true
  # (Integer) The number of seconds the authenticated url will be valid (3600 seconds = 1 hour)
  # config.clean_up_older_than = 3600
  # (Boolean) Useful for environments such as Heroku
  # config.fail_silently = true
end
