# cloud_tempfile/storage.rb
#
# Author::    Kevin Bolduc
# Date::      14-02-24
# Time::      3:23 PM

module CloudTempfile
  class Storage

    attr_accessor :config

    def initialize(cfg)
      @config = cfg
    end

    # This "connection" is the fog connection responsible for persisting the file
    # @return [Fog::Storage]
    def connection
      @connection ||= ::Fog::Storage.new(self.config.fog_options)
    end

    # This "directory" action should only be used with the cloud provider and returns a <tt>Fog::Storage::Directory</tt> class
    # @return [Fog::Storage::Directory]
    def directory(options={})
      prefix = options.has_key?(:prefix)? options[:prefix] : self.config.prefix
      @directory ||= connection.directories.get(self.config.fog_directory, :prefix => prefix)
    end

    # This action will upload a Fog::Storage::File to the specified directory
    # @return [Fog::Storage::File]
    def upload_file(f, body, options={})
      file = init_fog_file(f, body, options)
      if self.config.enabled?
        return directory(options).files.create( file )
      else
        return local_file(f, body, options)
      end
    end

    # Used with the "Local" provider which will utilize the local file system with Fog.
    # This is handy for development and test environments.
    # @return [Fog::Storage::Local::File]
    def local_file(f, body, options={})
      #return !self.config.public?
      file = init_fog_file(f, body, options)
      # If the "file" is empty then return nil
      return nil if file.nil? || file.blank? || local_root.nil?
      file = local_root(options).files.create( file )
    end

    # This action will delete a AWS::File from the specified directory
    # @param [Fog::Storage::File]
    def delete_file(f)
      #return false if !f.kind_of?(Fog::Storage::AWS::File) || !storage_provider.eql?(:aws)
      log "Deleting: #{f.key}"
      return f.destroy
    end

    # Returns a list of remote files for the specified directory
    # @throws [BucketNotFound]
    # @return [Array]
    def get_remote_files
      raise BucketNotFound.new("#{self.config.fog_provider} Bucket: #{self.config.fog_directory} not found.") unless directory
      files = []
      directory.files.each { |f| files << f.key if File.extname(f.key).present? }
      return files
    end

    # Delete the expired file which are expired if the "config.clean_up" is true
    # and "config.clean_up_older_than" is the amount of seconds it is older than.
    #
    # Note: This action should be used with the "bundle exec rake cloud_temp_file:clear" rake command (cronjob)
    def delete_expired_tempfiles
      return if !self.config.clean_up? || !self.config.enabled?
      log "CloudTempfile.delete_expired_tempfiles is running..."
      # Delete expired temp files
      get_remote_files.each do |f|
        f = directory.files.get(f)
        if f.last_modified <= self.config.clean_up_older_than.ago
          delete_file(f)
        end
      end
      log "CloudTempfile.delete_expired_tempfiles is complete!"
    end

    # Custom Errors (Exceptions)
    class BucketNotFound < StandardError; end

    private

    # Initialize a Hash object to be use to by <tt>Fog::Storage</tt> to persist
    # @param [String] filename
    # @param [Object] body
    # @return [Hash]
    def init_fog_file(filename, body, options={})
      # If the "filename" or the "body" are empty then return nil
      return nil if filename.nil? || body.nil?
      # Set file's access control list (ACL).

      aws_acl = (self.config.aws_acl?)? self.config.aws_access_control_list.to_s : nil
      # expiry is the number of seconds the file will available publicly
      expiry = options.has_key?(:expiry)? options[:expiry] : ((self.config.expiry?)? self.config.expiry.to_i : nil)
      ext = File.extname(filename)[1..-1] # The file extension
      mime = MultiMime.lookup(ext) # Look up the content type based off the file extension
      prefix = options.has_key?(:prefix)? options[:prefix] : self.config.prefix
      full_filename = (self.config.local? || !self.config.enabled?)? filename : "#{prefix}#{filename}"

      # file Hash to be used to create a Fog for upload
      file = {
        :key => "#{full_filename}",
        :body => body,
        :content_type => mime
      }

      file.merge!({:public => true}) if self.config.public?

      if self.config.aws?
        if self.config.public? && self.config.expiry?
          file.merge!({:cache_control => "public, max-age=#{expiry}"})
        end
        # valid acls: private, public-read, public-read-write, authenticated-read, bucket-owner-read, bucket-owner-full-control
        file.merge!({:acl=>self.config.aws_access_control_list.to_s}) if self.config.aws_acl?
        file.merge!({:expires => Time.now.utc.to_i + expiry}) if self.config.expiry?
        file.merge!({:storage_class => 'REDUCED_REDUNDANCY'}) if self.config.aws_rrs?
      end

      return file
    end

    # This "local_root" action should only be used with the "Local" provider and returns a Fog::Storage::Local::Directory class
    # @return [Fog::Storage::Local::Directory]
    def local_root(options={})
      prefix = options.has_key?(:prefix)? options[:prefix] : self.config.prefix

      begin
        if !connection.directories.get(prefix).nil?
          @local_root ||= connection.directories.get(prefix)
        else
          @local_root ||= connection.directories.create(:key => prefix)
        end
      rescue
        @local_root ||= connection.directories.create(:key => prefix)
      end
    end

    def log(msg)
      CloudTempfile.log(msg)
    end

  end
end
