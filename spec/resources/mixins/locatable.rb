require 'rubygems'
require 'rspec'
require 'addressable/uri'
require 'addressable/template'

require 'lib/resources/mixins/locatable'

module MicroScraper::Resources
  describe Locatable do
    let!(:default_template) do
      Locatable.get_template
    end

    let!(:alternate_template) do
      Locatable::Template.new({
                              :root => Addressable::URI.parse('/alternate/'),
                              :model => Addressable::Template.new('models/{model}/'),
                              :resource => Addressable::Template.new('{-suffix|-|within}{title}') 
                            })
    end

    let!(:test_module) do
      Locatable
    end

    let!(:test_model) do
      LocatableModel = Class.new do
        include 
      end
    end

    let!(:test_resource) do
      test_model.new
    end
    
    puts test_module
    describe test_module do
      it 'should have a default template' do
        puts test_module
        test_module.get_template.class.should == alternate_template.class
      end
      
      it 'should change templates' do
        test_module.set_template(alternate_template)
        test_module.get_template.should == alternate_template
        test_module.get_template.should != default_template
        test_module.set_template(default_template)
        test_module.get_template.should != alternate_template
        test_module.get_template.should == default_template
      end
    end

    describe test_model, '#location' do    
      it 'generates uri with default template' do
        test_model.location.should == Addressable::URI.parse('/TestLocatable/')
      end
    end

    describe test_resource, '#location' do
      it 'generates uri with default template' do
        test_resource.location.should == Addressable::URI.parse('/TestLocatable/title')
      end
    end
  end
end
