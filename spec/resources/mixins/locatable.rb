require 'rubygems'
require 'rspec'
require 'addressable/uri'

require 'lib/resources/mixins/locatable'

describe MicroScraper::Resources::Locatable, '#uri' do
  class TestModel
    include MicroScraper::Resources::Locatable
  end
  
  it 'provides uri for model' do
    TestModel.location.should == Addressable::URI.parse('/TestModel/')
  end

  it 'provides uri for resource' do
    resource = TestModel.new(:title => 'title')
    resource.location.should == Addressable::URI.parse('/TestModel/title')
  end
end
