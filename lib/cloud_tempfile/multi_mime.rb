# -*- ruby encoding: utf-8 -*-
#
# cloud_tempfile/multi_mime.rb
#
# Author::    Kevin Bolduc
# Date::      14-02-24
# Time::      3:23 PM

require 'mime/types'

module CloudTempfile
  class MultiMime
    def self.lookup(ext)
      if defined?(Mime::Type)
        Mime::Type.lookup_by_extension(ext)
      elsif defined?(Rack::Mime)
        ext_with_dot = ".#{ext}"
        Rack::Mime.mime_type(ext_with_dot)
      else
        MIME::Types.type_for(ext).first
      end
    end
  end
end