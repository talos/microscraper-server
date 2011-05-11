require 'spec/spec_helper'

module MicroScraper::Resource
  shared_examples_for 'resource' do
    before(:each) do
      @model = subject
      @resource = subject.new
    end
    
    it 'is a DataMapper model' do
      @model.included_modules.should include(DataMapper::Model)
    end

    it 'produces a DataMapper resource' do
      @resource.included_modules.should include(DataMapper::Resource)
    end
  end
end
