require 'rubygems'
require 'rspec'

require 'lib/resources/mixins/linkable'

module MicroScraper::Resources
  class LinkableModel
    include Linkable
  end

  describe LinkableModel do
    it 'is a DataMapper model' do

    end

    it 'has a serial id property' do

    end

    it 'provides links_to method for definition' do

    end

    it 'extends Model that it links_to with Linkable' do

    end
  end

  describe LinkableModel.new do
    it 'is a DataMapper resource' do

    end

    it 'provides ref method' do
      should respond_to(:ref)
    end
    
    it 'returns string as ref' do
      subject.ref.class.should eql(String)
    end

    it 'has unique ref inside model' do
      
    end

    it 'has unique ref compared to other models' do

    end
  end
end
