require File.dirname(__FILE__) + '/../spec_helper'

RSpec.configure do |c|
  c.filter_run_excluding :ignore => true
end

describe CloudTempfile::Storage do
  include_context "mock Rails without_yml"

  describe 'Local#upload_file', :ignore => false do
    before(:each) do
      @config = CloudTempfile::Config.new
      @config.enabled = true
      @config.fog_provider = "Local"

      @storage = CloudTempfile::Storage.new(@config)
    end

    it 'accepts a PDF file and raw filedata' do
      filename = 'TEST.pdf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      @storage.local_file(filename, file)
    end

    it 'accepts a DOC file and raw filedata' do
      filename = 'TEST.doc'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      @storage.local_file(filename, file)
    end

    it 'accepts a DOCX file and raw filedata' do
      filename = 'TEST.docx'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      @storage.local_file(filename, file)
    end

    it 'accepts a RTF file and raw filedata' do
      filename = 'TEST.rtf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      @storage.local_file(filename, file)
    end

    it 'still accepts a file and config.enabled is false' do
      filename = 'TEST.rtf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      @config.enabled = false

      @storage.local_file(filename, file)
    end
  end

  describe 'AWS#upload_file', :ignore => false do
    before(:each) do
      #Enable/Disable Fog mocking by enivronment variables for testing
      @mock = ((ENV['RSPEC_MOCK'].nil?)? ((ENV['AWS_ACCESS_KEY_ID'].nil?)? true : ENV['AWS_ACCESS_KEY_ID']) : ENV['RSPEC_MOCK']=='true')

      Fog.mock! if @mock

      @config = CloudTempfile::Config.new
      @config.enabled = true
      @config.fog_provider = "AWS"
      @config.aws_access_key_id = !@mock? ENV['AWS_ACCESS_KEY_ID'] : 'KEY'
      @config.aws_secret_access_key = !@mock? ENV['AWS_SECRET_ACCESS_KEY'] : 'SECRET_KEY'
      @config.aws_reduced_redundancy = true
      @config.fog_directory = !@mock? ENV['FOG_DIRECTORY'] : 'bucket'
      @config.prefix = "tmp-test/"
      @config.public = true

      @storage = CloudTempfile::Storage.new(@config)
    end

    after(:each) do
      Fog.unmock! if @mock
    end

    it 'accepts a PDF file and raw filedata' do
      filename = 'TEST.pdf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      file = @storage.upload_file(filename, file)
    end

    it 'accepts a DOC file and raw filedata' do
      filename = 'TEST.doc'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      @storage.upload_file(filename, file)
    end

    it 'accepts a DOCX file and raw filedata' do
      filename = 'TEST.docx'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      @storage.upload_file(filename, file)
    end

    it 'accepts a RTF file and raw filedata' do
      filename = 'TEST.rtf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      @storage.upload_file(filename, file)
    end

    it 'has public visibility' do
      filename = 'TEST.pdf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      # public: When true, asset is public. When false, asset is private.
      @config.public = true

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      file = @storage.upload_file(filename, file)
      file.public_url.should_not be_nil if !@mock
    end

    it 'has private visibility' do
      filename = 'TEST.pdf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      # public: When true, asset is public. When false, asset is private.
      @config.public = false

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      file = @storage.upload_file(filename, file)
      file.public_url.should be_nil if !@mock
    end

    it 'has private visibility and expiry' do
      filename = 'TEST.pdf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      # public: When true, asset is public. When false, asset is private.
      @config.public = false
      @config.expiry = 60

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      file = @storage.upload_file(filename, file)
      file.public_url.should_not be_nil if !@mock
    end
  end

  describe 'AWS#upload_file with CloudTempfile disabled', :ignore => false do
    before(:each) do
      @config = CloudTempfile::Config.new
      @config.enabled = false
      @config.fog_provider = "AWS"
      @config.aws_access_key_id = !@mock? ENV['AWS_ACCESS_KEY_ID'] : 'KEY'
      @config.aws_secret_access_key = !@mock? ENV['AWS_SECRET_ACCESS_KEY'] : 'SECRET_KEY'
      @config.fog_directory = !@mock? ENV['FOG_DIRECTORY'] : 'bucket'
      @config.prefix = "tmp-test/"
      @config.public = true

      #Enabled Fog mocking
      @mock = false
      Fog.mock! if @mock

      @storage = CloudTempfile::Storage.new(@config)
    end

    after(:each) do
      Fog.unmock! if @mock
    end


    it 'still accepts a file and config.enabled is false, however is should write locally' do
      filename = 'TEST.pdf'
      file = File.open(File.dirname(__FILE__) + '/../fixtures/assets/' + filename)

      @config.enabled = false

      if @mock
        directory = double
        files = double

        @storage.stub(:directory).and_return(directory)
        directory.stub(:files).and_return(files)

        files.should_receive(:create)
      end

      file = @storage.upload_file(filename, file)
      file.should_not be_nil
      file.public_url.should_not be_nil
    end
  end
end


