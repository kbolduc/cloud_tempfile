# RELEASE HISTORY

## v1.0.1 / 2016-04-06

Version 1.0.1 (Kevin Bolduc)

Changes:
    * Adding the new Appraisials to the CI travis.yml to test rails versions
    * Updating dev dependencies for the gem.
    * Updating the Appraisals used for testing against other versions of rails.
    * Update the ruby gemset and version required for Ruby Managers
    * Fixing the issue with Time comparison when cleaning up expired assets (rake task)
    * Added the Mime::Types as a required library
    * Hardening required dependency versions.

## v0.0.5 / 2014-05-20

Version 0.0.5 (Kevin Bolduc)

Changes:
    * Allow for the attachment disposition option

## v0.0.4 / 2014-03-22

Version 0.0.4 (Kevin Bolduc)

Changes:
    * #7: When config.public is set to false it is generating a public url by default. This should be a private generated url.

## v0.0.3 / 2014-03-21

Version 0.0.3 (Kevin Bolduc)

Changes:
    * #6: Default to local file storage when config.enabled is false
    * #5: Update the config.public_path to be intialized when Rails is defined
    * #4: When fog_provider is "Local", CloudTempfile::Config::Invalid (Fog directory Can't be blank) is thrown
    * #3: CloudTempfile::Config::Invalid (Public Can't be blank)

## v0.0.2 / 2014-03-13

Version 0.0.2 (Kevin Bolduc)

Changes:
    * #1 Add Code Climate metric reporting support
    * #2 Allow the option to override the expiry when uploading a file to the Cloud

## v0.0.1 / 2014-03-12

Version 0.0.1 (Kevin Bolduc)

Changes:
    * v0.0.1 CloudTempfile
    * Updated README.md
    * Initial commit
