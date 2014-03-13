# cloud_tempfile/cloud_tempfile.rb
#
# Author::    Kevin Bolduc
# Date::      14-02-24
# Time::      3:23 PM

module CloudTempfile

  class << self
    attr_accessor :file_name
    attr_accessor :file_raw_data

    def initialize(file_name=nil, file_raw_data=nil)
      self.file_name = file_name
      self.file_raw_data = file_raw_data
    end


    def config=(data)
      @config = data
    end

    def config
      @config ||= Config.new
      @config
    end

    def reset_config!
      remove_instance_variable :@config if defined?(@config)
    end

    def configure(&proc)
      @config ||= Config.new
      yield @config
    end

    def storage
      @storage ||= Storage.new(self.config)
    end

    # This action will responsible for persisting the Tempfile
    # == Options
    # [:+file_name+:] The file name to use for the Tempfile
    # [:+file_raw_data+:] The raw file data to be persisted
    # [:+expiry+:] The expiry is the number of seconds the file will available publicly
    #
    # @param [Hash] options The Hash of options
    # @return [File]
    def write(options = {})
      _file_name = ((options.has_key?(:file_name))? options[:file_name] : self.file_name)
      _file_raw_data = ((options.has_key?(:file_raw_data))? options[:file_raw_data] : self.file_raw_data)

      return false if _file_name.nil? || _file_name.blank? || _file_raw_data.nil?

      with_config do
        if !(config && config.local?)
          return self.storage.upload_file(_file_name, _file_raw_data, options)
        else
          return self.storage.local_file(_file_name, _file_raw_data, options)
        end
      end
    end

    # Delete the remote file which are expired if the "config.clean_up" is true
    # and "config.clean_up_older_than" is the amount of seconds it is older than.
    #
    # Note: This action should be used with the "bundle exec rake cloud_tempfile:clear" rake command (cronjob)
    def clear
      with_config do
        self.storage.delete_expired_tempfiles
      end
    end

    def with_config(&block)
      return unless CloudTempfile.enabled?

      errors = config.valid? ? "" : config.errors.full_messages.join(', ')

      if !(config && config.valid?)
        if config.fail_silently?
          self.warn(errors)
        else
          raise Config::Invalid.new(errors)
        end
      else
        block.call
      end
    end

    def warn(msg)
      stderr.puts msg
    end

    def log(msg)
      stdout.puts msg if config.log_silently?
    end

    def enabled?
      config.enabled?
    end

    # Log Stub methods
    def stderr ; STDERR ; end
    def stdout ; STDOUT ; end

  end
end
