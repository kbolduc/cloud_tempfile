require 'fog'
require 'active_model'
require 'erb'
require 'ext/fog/aws/models/storage/file'
require 'cloud_tempfile/cloud_tempfile'
require 'cloud_tempfile/config'
require 'cloud_tempfile/storage'
require 'cloud_tempfile/multi_mime'

require 'cloud_tempfile/railtie' if defined?(Rails)
require 'cloud_tempfile/engine'  if defined?(Rails)