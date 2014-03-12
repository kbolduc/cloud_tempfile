[![Build Status](https://secure.travis-ci.org/kbolduc/cloud_tempfile.png)](http://travis-ci.org/kbolduc/cloud_tempfile)
[![Dependency Status](https://gemnasium.com/kbolduc/cloud_tempfile.png)](https://gemnasium.com/kbolduc/cloud_tempfile)
[![Code Climate](https://codeclimate.com/github/kbolduc/cloud_tempfile.png)](https://codeclimate.com/github/kbolduc/cloud_tempfile)
[![Coverage Status](https://coveralls.io/repos/kbolduc/cloud_tempfile/badge.png?branch=master)](https://coveralls.io/r/kbolduc/cloud_tempfile?branch=master)
[![Gem Version](https://badge.fury.io/rb/cloud_tempfile.png)](http://badge.fury.io/rb/cloud_tempfile)
[![Gittip](http://img.shields.io/gittip/kbolduc.png)](https://www.gittip.com/kbolduc/)

# CloudTempfile

Tempfile creation directly on Amazon S3 which can be utilized by a Ruby on Rails application.

This was initially built and is intended to work on [Heroku](http://heroku.com) but can work on any platform.

## Installation

Add the gem to your Gemfile

``` ruby
gem 'cloud_tempfile'
```

## Configuration

### CloudTempfile

**CloudTempfile** supports the following methods of configuration.

* [Built-in Initializer](https://github.com/kbolduc/cloud_tempfile/blob/master/lib/cloud_tempfile/engine.rb) (configured through environment variables)
* Rails Initializer
* A YAML config file


Using the **Built-in Initializer** is the default method and is supposed to be used with **environment** variables. It's the recommended approach for deployments on Heroku.

If you need more control over configuration you will want to use a **custom rails initializer**.

Configuration using a **YAML** file (a common strategy for Capistrano deployments) is also supported.

The recommend way to configure **cloud_tempfile** is by using **environment variables** however it's up to you, it will work fine if you hard code them too. The main reason is that then your access keys are not checked into version control.

### Built-in Initializer (Environment Variables)

The Built-in Initializer will configure **CloudTempfile** based on the contents of your environment variables.

Add your configuration details to **heroku**

``` bash
heroku config:add AWS_ACCESS_KEY_ID=xxxx
heroku config:add AWS_SECRET_ACCESS_KEY=xxxx
heroku config:add FOG_DIRECTORY=xxxx
heroku config:add FOG_PROVIDER=AWS
# and optionally:
heroku config:add FOG_REGION=eu-west-1
```

Or add to a traditional unix system

``` bash
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx
export FOG_DIRECTORY=xxxx
```

Rackspace configuration is also supported

``` bash
heroku config:add RACKSPACE_USERNAME=xxxx
heroku config:add RACKSPACE_API_KEY=xxxx
heroku config:add FOG_DIRECTORY=xxxx
heroku config:add FOG_PROVIDER=Rackspace
```

Google Storage Cloud configuration is supported as well
``` bash
heroku config:add FOG_PROVIDER=Google
heroku config:add GOOGLE_STORAGE_ACCESS_KEY_ID=xxxx
heroku config:add GOOGLE_STORAGE_SECRET_ACCESS_KEY=xxxx
heroku config:add FOG_DIRECTORY=xxxx
```

### Custom Rails Initializer (config/initializers/cloud_tempfile.rb)

If you want to enable some of the advanced configuration options you will want to create your own initializer.

Run the included Rake task to generate a starting point.

    rails g cloud_tempfile:install --provider=Rackspace
    rails g cloud_tempfile:install --provider=AWS

The generator will create a Rails initializer at `config/initializers/cloud_tempfile.rb`.

``` ruby
CloudTempfile.configure do |config|
  config.enabled = true
  config.fog_provider = 'AWS'
  config.fog_directory = ENV['FOG_DIRECTORY']
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']

  # Increase upload performance by configuring your region
  # config.fog_region = 'eu-west-1'
  #
  # Fail silently.  Useful for environments such as Heroku
  # config.fail_silently = true
end
```

### YAML (config/cloud_tempfile.yml)

Run the included Rake task to generate a starting point.

    rails g cloud_tempfile:install --use-yml --provider=Rackspace
    rails g cloud_tempfile:install --use-yml --provider=AWS

The generator will create a YAML file at `config/cloud_tempfile.yml`.

``` yaml
defaults: &defaults
  enabled: true
  fog_provider: "AWS"
  fog_directory: "rails-app-assets"
  aws_access_key_id: "<%= ENV['AWS_ACCESS_KEY_ID'] %>"
  aws_secret_access_key: "<%= ENV['AWS_SECRET_ACCESS_KEY'] %>"
  # You may need to specify what region your storage bucket is in
  # fog_region: "eu-west-1"
  # Fail silently.  Useful for environments such as Heroku
  # fail_silently: true


development:
  <<: *defaults
  enabled: false

test:
  <<: *defaults
  enabled: false

production:
  <<: *defaults
```

### Available Configuration Options

All CloudTempfile configuration can be modified directly using environment variables with the **Built-in initializer**. e.g.

```ruby
CloudTempfile.config.fog_provider == ENV['FOG_PROVIDER']
```

#### CloudTempfile (optional)

* **enabled**: (`true, false`) when false, will disable CloudTempfile and local Tempfile will be created instead.
* **default:** `'false'` (disabled)

#### Fog (Required)
* **fog\_provider**: your storage provider *AWS* (S3) or *Rackspace* (Cloud Files) or *Google* (Google Storage)
* **fog\_directory**: your bucket name

#### Fog (Optional)

* **fog\_region**: the region your storage bucket is in e.g. *eu-west-1*

#### AWS

* **aws\_access\_key\_id**: your Amazon S3 access key
* **aws\_secret\_access\_key**: your Amazon S3 access secret

#### Rackspace

* **rackspace\_username**: your Rackspace username
* **rackspace\_api\_key**: your Rackspace API Key.

#### Google Storage
* **google\_storage\_access\_key\_id**: your Google Storage access key
* **google\_storage\_secret\_access\_key**: your Google Storage access secret

#### Rackspace (Optional)

* **rackspace\_auth\_url**: Rackspace auth URL, for Rackspace London use: `https://lon.identity.api.rackspacecloud.com/v2.0`

## Amazon S3 Multiple Region Support

If you are using anything other than the US buckets with S3 then you'll want to set the **region**. For example with an EU bucket you could set the following environment variable.

``` bash
heroku config:add FOG_REGION=eu-west-1
```

Or via a custom initializer

``` ruby
CloudTempfile.configure do |config|
  # ...
  config.fog_region = 'eu-west-1'
end
```

Or via YAML

``` yaml
production:
  # ...
  fog_region: 'eu-west-1'
```

## Rake Task

A rake task is included within the **cloud_tempfile** gem to perform the clean up:

``` ruby
    namespace :cloud_tempfile do
      desc "Clean up expired temp files from the remote storage"
      task :clear => :environment do
        CloudTempfile.clear
      end
    end
```

## Todo

1. Support more cloud storage providers
3. Better test coverage

## Credits

Inspired by:

 - [https://devcenter.heroku.com/articles/dynos#ephemeral-filesystem](https://devcenter.heroku.com/articles/dynos#ephemeral-filesystem)

## License

MIT License. Copyright 2014 Kevin Bolduc.
