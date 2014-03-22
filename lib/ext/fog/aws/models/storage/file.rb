require 'fog/aws/models/storage/file'

module Fog
  module Storage
    class AWS

      class File
        fog_public_url = instance_method(:public_url)

        define_method(:public_url) do
          return_url = fog_public_url.bind(self).call()
          expires_url = url(expires) if !expires.nil?
          return (expires_url.nil?)? return_url : expires_url
        end
      end

    end
  end
end
