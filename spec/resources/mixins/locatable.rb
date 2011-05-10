require 'rubygems'
require 'rspec'
require 'addressable/uri'
require 'addressable/template'

require 'lib/resources/mixins/locatable'

module MicroScraper::Resources
  class LocatableModel
    include Locatable
  end

  describe LocatableModel, '#location' do
    it 'is a DataMapper model' do

    end
    
    it 'has location method' do
      should respond_to(:location)
    end
    
    it 'generates model uri' do
      subject.location.class.should eq(Addressable::URI)
    end
  end
  
  describe LocatableModel.new(:title => 'title'), '#location' do
    it 'is a DataMapper resource' do

    end

    it 'has location method' do
      should respond_to(:location)
    end
    
    it 'generates resource uri' do
      subject.location.class.should eq(Addressable::URI)
    end
  end
end
