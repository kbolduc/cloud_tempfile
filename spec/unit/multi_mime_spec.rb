require File.dirname(__FILE__) + '/../spec_helper'

describe CloudTempfile::MultiMime do

  before(:each) do
    Object.send(:remove_const, :Rails) if defined?(Rails)
    Object.send(:remove_const, :Mime) if defined?(Mime)
    Object.send(:remove_const, :Rack) if defined?(Rack)
  end

  after(:each) do
    Object.send(:remove_const, :Rails) if defined?(Rails)
    Object.send(:remove_const, :Mime) if defined?(Mime)
    Object.send(:remove_const, :Rack) if defined?(Rack)
  end

  after(:all) do
    require 'mime/types'
  end

  describe 'Mime::Type' do

    it 'should detect mime type' do
      #require 'rails'
      #CloudTempfile::MultiMime.lookup('css').should == "text/css"
    end

  end

  describe 'Rack::Mime' do

    it 'should detect mime type' do
      require 'rack/mime'
      CloudTempfile::MultiMime.lookup('css').should == "text/css"
    end

  end

  describe 'MIME::Types' do

    it 'should detect mime type' do
      require 'mime/types'
      CloudTempfile::MultiMime.lookup('css').should == "text/css"
    end

  end

end