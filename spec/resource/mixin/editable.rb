require 'spec/resource/mixin'
require 'lib/resource/user'

module MicroScraper::Resource::Mixin
  shared_examples_for 'editable resource' do
    it_should_behave_like 'resource mixin'
    
    before(:each) do
      def generate_user
        MicroScraper::Resource::User.new
      end
      @creator = generate_user
      @resource.creator = @creator

      @editors = 5.times.collect { generate_user }
      @resource.editors << @editors
      
      @rando = generate_user
    end
    
    it 'must be saved by a User' do
      @resource.should_not respond_to(:save).with(0).argument
      @someone.save(@creator).should_not raise_error
    end
    
    it 'belongs_to a User "creator"' do
      @resource.creator.should eq(@creator)
    end

    it 'has n User "editors"' do
      @resource.editors.should include(*@editors)
      @editors.each do |editor|
        @resource.editors.should include(editor)
      end
    end

    it 'can be saved by its creator' do
      @creator.save(@resource).should be_true
    end

    it 'can be saved by its editors' do
      @editors.each do |editor|
        editor.save(@resource).should be_true
      end
    end

    it 'does not save when someone random tries to save it' do
      @rando.save(@resource).should_not be_true
    end
    
    it 'raises an exception when someone random tries to save it' do
      @rando.save(@resource).should raise_error
    end
    
    it 'raises an exception when the creator is added as another editor' do
      expect {
        @resource.editors << @creator
        @creator.save(@resource)
      }.to raise_error
    end

    it 'raises an exception when the creator is reassigned' do
      expect {
        @resource.creator = @rando
        @creator.save(@resource)
      }.to raise_error
    end
  end
end
