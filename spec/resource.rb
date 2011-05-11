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
    
    # Helper method to find path to this resource
    # @return [String] path within 'resource' directory for this file
    # @example
    #   resource_path #=> "./resource/web_page"
    def resource_path
      '.' + Dir[File.dirname(__FILE__)][/\/resource\/.*/]
    end
    
    let(:model)      { subject }
    let(:collection) { subject.all }
    let(:instance)   { subject.new }

    after(:each) do
      if instance
        instance.destroy!
      end
    end
    
    describe 'model' do
      subject { model }
      it { should be_a(DataMapper::Model) }
      
      it 'should behave like a sweatshop' do
        should respond_to(:generate)
        should respond_to(:make)
        should respond_to(:gen)
      end

      describe '#make' do
        it 'makes valid instances' do
          model.make.valid?.should be_true
        end

        it 'makes instances of correct class' do
          model.generate.should be_instance_of(instance.class)
        end
      end
    end
    
    describe 'collection' do
      subject { collection }
      it { should be_a(DataMapper::Collection) }
    end

    describe 'instance' do
      subject { instance }
      it { should be_a(DataMapper::Resource) }
    end
  end
end
