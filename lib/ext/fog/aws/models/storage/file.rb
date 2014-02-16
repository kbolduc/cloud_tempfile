require 'fog/aws/models/storage/file'

module Fog
  module Storage
    class AWS

      class File
        fog_public_url = instance_method(:public_url)

        define_method(:public_url) do
          return_url = fog_public_url.bind(self).call()
          return_url = url(expires) if return_url.nil? && !expires.nil?
          return return_url
        end
      end

    end
  end
end
