require File.dirname(__FILE__) + '/../spec_helper'

describe CloudTempfile do
  include_context "mock Rails without_yml"

  describe 'with initializer' do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.configure do |config|
        config.fog_provider = 'AWS'
        config.aws_access_key_id = 'aaaa'
        config.aws_secret_access_key = 'bbbb'
        config.fog_directory = 'mybucket'
        config.fog_region = 'eu-west-1'
      end
    end

    it "should default CloudTempfile to enabled" do
      CloudTempfile.config.enabled?.should == true
      CloudTempfile.enabled?.should == true
    end

    it "should configure provider as AWS" do
      CloudTempfile.config.fog_provider.should == 'AWS'
      CloudTempfile.config.should be_aws
    end

    it "should configure clean up remote files" do
      CloudTempfile.config.clean_up?.should == false
    end

    it "should configure aws_access_key" do
      CloudTempfile.config.aws_access_key_id.should == "aaaa"
    end

    it "should configure aws_secret_access_key" do
      CloudTempfile.config.aws_secret_access_key.should == "bbbb"
    end

    it "should configure aws_access_key" do
      CloudTempfile.config.fog_directory.should == "mybucket"
    end

    it "should configure fog_region" do
      CloudTempfile.config.fog_region.should == "eu-west-1"
    end

    it "should default log_silently to true" do
      CloudTempfile.config.log_silently.should == true
    end
  end

  describe 'from yml' do
    before(:each) do
      set_rails_root('aws_with_yml')
      CloudTempfile.config = CloudTempfile::Config.new
    end

    it "should default CloudTempfile to enabled" do
      CloudTempfile.config.enabled?.should == true
      CloudTempfile.enabled?.should == true
    end

    it "should configure aws_access_key_id" do
      CloudTempfile.config.aws_access_key_id.should == "xxxx"
    end

    it "should configure aws_secret_access_key" do
      CloudTempfile.config.aws_secret_access_key.should == "zzzz"
    end

    it "should configure fog_directory" do
      CloudTempfile.config.fog_directory.should == "rails_app_test"
    end

    it "should configure fog_region" do
      CloudTempfile.config.fog_region.should == "us-east-1"
    end

    it "should configure clean up remote files" do
      CloudTempfile.config.clean_up?.should == false
    end
  end

  describe 'from yml, overriding to stagging envrionment (disabled)' do
    before(:each) do
      Rails.env.replace('staging')
      set_rails_root('aws_with_yml')
      CloudTempfile.config = CloudTempfile::Config.new
    end

    it "should be disabled" do
      expect{ CloudTempfile.clear }.not_to raise_error()
    end

    after(:each) do
      Rails.env.replace('test')
    end
  end

  describe 'with no configuration' do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
    end

    it "should be invalid" do
      expect{ CloudTempfile.sync }.to raise_error()
    end
  end

  describe "with no other configuration than enabled = false" do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.configure do |config|
        config.enabled = false
      end
    end

    it "should do nothing, without complaining" do
      expect{ CloudTempfile.clear }.not_to raise_error()
    end
  end

  describe 'with fail_silent configuration' do
    before(:each) do
      CloudTempfile.stub(:stderr).and_return(@stderr = StringIO.new)
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.configure do |config|
        config.fail_silently = true
      end
    end

    it "should not raise an invalid exception" do
      expect{ CloudTempfile.clear }.not_to raise_error()
    end
  end

  describe 'with disabled config' do
    before(:each) do
      CloudTempfile.stub(:stderr).and_return(@stderr = StringIO.new)
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.configure do |config|
        config.enabled = false
      end
    end

    it "should not raise an invalid exception" do
      lambda{ CloudTempfile.clear }.should_not raise_error()
    end
  end

  describe 'with aws_reduced_redundancy enabled' do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.config.aws_reduced_redundancy = true
    end

    it "config.aws_rrs? should be true" do
      CloudTempfile.config.aws_rrs?.should == true
    end
  end

  describe 'with prefix set' do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.config.prefix = "dev/tmp/"
    end

    it "config.prefix should be set" do
      CloudTempfile.config.prefix.should == "dev/tmp/"
    end
  end

  describe 'with public enabled' do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.config.public = true
    end

    it "config.public? should be true" do
      CloudTempfile.config.public?.should == true
    end
  end

  describe 'with clean_up enabled' do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.config.clean_up = true
    end

    it "config.clean_up? should be true" do
      CloudTempfile.config.clean_up?.should == true
    end
  end

  describe 'with invalid yml' do

    before(:each) do
      set_rails_root('with_invalid_yml')
      CloudTempfile.config = CloudTempfile::Config.new
    end

    it "config should be valid" do
      CloudTempfile.config.valid?.should == true
    end
  end

end
