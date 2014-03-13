# cloud_tempfile/config.rb
#
# Author::    Kevin Bolduc
# Date::      14-02-24
# Time::      3:23 PM

module CloudTempfile
  class Config
    include ActiveModel::Validations

    # CloudTempfile
    attr_accessor :enabled

    attr_accessor :prefix
    attr_accessor :public
    attr_accessor :public_path
    attr_accessor :expiry
    attr_accessor :clean_up
    attr_accessor :clean_up_older_than

    # FOG configuration
    attr_accessor :fog_host              #
    attr_accessor :fog_provider          # Currently Supported ['AWS', 'Google', 'Rackspace', 'Local']
    attr_accessor :fog_directory         # e.g. 'the-bucket-name'
    attr_accessor :fog_region            # e.g. 'eu-west-1' or 'us-east-1' etc...
    attr_accessor :fog_endpoint          # e.g. '/'

    # Amazon AWS
    attr_accessor :aws_access_key_id, :aws_secret_access_key, :aws_reduced_redundancy, :aws_access_control_list

    # Rackspace
    attr_accessor :rackspace_username, :rackspace_api_key, :rackspace_auth_url

    # Google Storage
    attr_accessor :google_storage_secret_access_key, :google_storage_access_key_id

    # Logging Options
    attr_accessor :fail_silently
    attr_accessor :log_silently

    # Validation #######################################################################################################
    validates :public,                :presence => true
    validates :fog_provider,          :presence => true
    validates :fog_directory,         :presence => true

    validates :aws_access_key_id,     :presence => true, :if => :aws?
    validates :aws_secret_access_key, :presence => true, :if => :aws?
    validates :rackspace_username,    :presence => true, :if => :rackspace?
    validates :rackspace_api_key,     :presence => true, :if => :rackspace?
    validates :google_storage_secret_access_key,  :presence => true, :if => :google?
    validates :google_storage_access_key_id,      :presence => true, :if => :google?

    ####################################################################################################################
    def initialize
      self.fog_region = nil
      self.fog_endpoint = '/'

      self.public = false
      self.prefix = "tmp/"
      self.expiry = 600 # 10 Min = 600 Seconds

      self.fail_silently = false
      self.log_silently = true

      self.clean_up = false
      self.clean_up_older_than = 86400 # 1 Day = 86400 Seconds

      load_yml! if defined?(Rails) && yml_exists?
    end

    def enabled?
      enabled == true
    end

    def public?
      public == true
    end

    def public_path
      @public_path || Rails.public_path
    end

    def expiry?
      !expiry.nil? && expiry.kind_of?(Fixnum)
    end

    def aws?
      fog_provider == 'AWS'
    end

    def aws_rrs?
      aws_reduced_redundancy == true
    end

    # Set file's access control list (ACL).
    # Valid acls: private, public-read, public-read-write, authenticated-read, bucket-owner-read, bucket-owner-full-control
    def aws_acl?
      ['private', 'public-read', 'public-read-write', 'authenticated-read', 'bucket-owner-read', 'bucket-owner-full-control'].include?(aws_access_control_list)
    end

    def rackspace?
      fog_provider == 'Rackspace'
    end

    def google?
      fog_provider == 'Google'
    end

    def local?
      fog_provider == 'Local'
    end

    def clean_up?
      clean_up == true
    end

    def fog_options
      #If the CloudTempfile is disabled then revert to local file creation
      @fog_provider = 'Local' if (!enabled? && !fog_provider.nil?)

      options = { :provider => fog_provider }
      if aws?
        options.merge!({
          :aws_access_key_id => aws_access_key_id,
          :aws_secret_access_key => aws_secret_access_key
        })
        options.merge!({:host => fog_host}) if !fog_host.blank?
      elsif rackspace?
        options.merge!({
          :rackspace_username => rackspace_username,
          :rackspace_api_key => rackspace_api_key
        })
        options.merge!({
          :rackspace_region => fog_region
        }) if fog_region
        options.merge!({ :rackspace_auth_url => rackspace_auth_url }) if rackspace_auth_url
      elsif google?
        options.merge!({
          :google_storage_secret_access_key => google_storage_secret_access_key,
          :google_storage_access_key_id => google_storage_access_key_id
        })
      elsif local?
        options.merge!({
          :local_root => public_path,
          :endpoint => fog_endpoint
        })
      else
        raise ArgumentError, "CloudTempfile Unknown provider: #{fog_provider} only AWS, Rackspace and Google are supported currently."
      end

      options.merge!({:region => fog_region}) if fog_region && !rackspace?
      return options
    end


    def yml_exists?
      defined?(Rails.root) ? File.exists?(self.yml_path) : false
    end

    def yml
      begin
        @yml ||= YAML.load(ERB.new(IO.read(yml_path)).result)[Rails.env] rescue nil || {}
      rescue Psych::SyntaxError
        @yml = {}
      end
    end

    def yml_path
      Rails.root.join("config", "cloud_tempfile.yml").to_s
    end

    def load_yml!
      self.enabled                = yml["enabled"] if yml.has_key?('enabled')

      self.fog_provider           = yml["fog_provider"]
      self.fog_directory          = yml["fog_directory"]
      self.fog_region             = yml["fog_region"]
      self.fog_host               = yml["fog_host"] if yml.has_key?("fog_host")
      self.aws_access_key_id      = yml["aws_access_key_id"]
      self.aws_secret_access_key  = yml["aws_secret_access_key"]
      self.aws_reduced_redundancy = yml["aws_reduced_redundancy"]
      self.rackspace_username     = yml["rackspace_username"]
      self.rackspace_auth_url     = yml["rackspace_auth_url"] if yml.has_key?("rackspace_auth_url")
      self.rackspace_api_key      = yml["rackspace_api_key"]
      self.google_storage_secret_access_key = yml["google_storage_secret_access_key"]
      self.google_storage_access_key_id     = yml["google_storage_access_key_id"]

      self.clean_up               = yml["clean_up"] if yml.has_key?("clean_up")
      self.clean_up_older_than    = yml["clean_up_older_than"] if yml.has_key?("clean_up_older_than")
      self.fail_silently          = yml["fail_silently"] if yml.has_key?("fail_silently")
      self.prefix                 = yml["prefix"] if yml.has_key?("prefix")
      self.public_path            = yml["public_path"] if yml.has_key?("public_path")
      self.expiry                 = yml["expiry"] if yml.has_key?("expiry")
    end

    def fail_silently?
      fail_silently || !enabled?
    end

    def log_silently?
      self.log_silently == false
    end

    class Invalid < StandardError; end
    private
  end
end