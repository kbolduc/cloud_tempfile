require File.dirname(__FILE__) + '/../spec_helper'

describe CloudTempfile do
  include_context "mock without Rails"

  describe 'with initializer' do
    before(:each) do
      CloudTempfile.config = CloudTempfile::Config.new
      CloudTempfile.configure do |config|
        config.fog_provider = 'AWS'
        config.aws_access_key_id = 'aaaa'
        config.aws_secret_access_key = 'bbbb'
        config.fog_directory = 'mybucket'
        config.fog_region = 'eu-west-1'
        config.public_path = Pathname("./public")
      end
    end

    it "should have prefix of assets" do
      CloudTempfile.config.public_path.to_s.should == "./public"
    end

    it "should default CloudTempfile to enabled" do
      CloudTempfile.config.enabled?.should be_true
      CloudTempfile.enabled?.should be_true
    end

    it "should configure provider as AWS" do
      CloudTempfile.config.fog_provider.should == 'AWS'
      CloudTempfile.config.should be_aws
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

  end
end
