# cloud_tempfile/railtie.rb
#
# Author::    Kevin Bolduc
# Date::      14-02-24
# Time::      3:23 PM

class Rails::Railtie::Configuration
  def cloud_tempfile
    CloudTempfile.config
  end
end