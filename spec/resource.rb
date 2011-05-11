require 'spec/spec_helper'

module MicroScraper::Resource
  shared_examples_for 'resource' do
    # How many times do we generically want to repeat something?
    let(:reps) { 5 }

    # Helper method for generating resources
    # @param [Class<MicroScraper::Resource>] klass class of the resource to produce
    # @param [optional, Fixnum] how_many resources to generate
    # @return [Array<MicroScraper::Resource>] array of resources
    def factory(klass, how_many = reps)
      how_many.times.collect { klass.generate }
    end
    
    before(:each) do
      @model = subject
      @resource = subject.new
    end
    
    it 'is a DataMapper model' do
      @model.should be_a(DataMapper::Model)
    end

    it 'produces a DataMapper resource' do
      @resource.should be_a(DataMapper::Resource)
    end

    it 'is a sweatshop' do
      @model.should respond_to(:generate)
      @model.should respond_to(:make)
      @model.should respond_to(:gen)
    end
    
    it 'produces valid resources' do
      @model.make.valid?.should be_true
      @model.generate.should be_instance_of(@resource.class)
    end
  end
end
