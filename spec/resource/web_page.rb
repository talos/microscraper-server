require 'spec/spec_helper.rb'
require 'spec/resource.rb'
require 'spec/resource/mixin/editable.rb'
require 'spec/resource/mixin/testable.rb'

require 'lib/resource/post'
require 'lib/resource/header'
require 'lib/resource/cookie'
require 'lib/resource/regexp'

module MicroScraper::Resource
  describe WebPage do
    it_should_behave_like 'resource'
    it_should_behave_like 'editable resource'
    it_should_behave_like 'testable resource'
    it_should_behave_like 'serializeable resource'
    
    # Helper method for testing a relationship
    # @param [Symbol] relationship symbol of relationship
    # @param [Array<DataMapper::Resource>] array of resources
    # @return 
    def test_relationship(relationship, resources)
      it 'has #{relationship}' do
        expect {
          resource.posts << posts
        }.to_not raise_error
        creator.save(resource).should be_true
        resource.posts.should include(*posts)
      end
    end

    let(:posts)   { factory.generate Post }
    let(:headers) { factory.generate Header }
    let(:cookies) { factory.generate Cookie }
    let(:regexps) { factory.generate Regexp }

    it 'has a single Addressable::URL url' do
      resource.url.should be_an(Addressable::URL)
    end

    it 'cannot have null url' do
      resource.url = nil
      resource.valid?.should be_false
      creator.save(resource).should be_false
    end

    it 'may request header only' do
      resource.should respond_to(:header_only?)
      resource.header_only?.should be_instance_of(Boolean)
    end

    it 'may request body' do
      resource.should respond_to(:requests_body?)
      resource.requests_body?.should be_instance_of(Boolean)
    end

    it 'either requests header only or requests body too' do
      resource.requests_body?.should_not eq(resource.header_only?)
    end

    describe 'header only web_page', :if => resource.header_only? do
      it 'has terminating regular expressions' do
        
      end
    end

    describe 'web_page with body', :if => resource.requests_body? do
      it 'does not have terminating regular expressions' do
        
      end
    end

    test_relationship(:posts, posts)
    test_relationship(:cookies, cookies)
    test_relationship(:headers, headers)
    test_relationship(:terminates, regexps)
  end
end
