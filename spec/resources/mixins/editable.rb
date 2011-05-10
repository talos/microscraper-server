require 'rubygems'
require 'rspec'

require 'lib/resources/mixins/editable'

module MicroScraper::Resources
  class EditableModel
    include Editable
  end
  
  describe EditableModel do
    it 'is a DataMapper model' do

    end

    it 'has a many-to-one relationship called creator to a User' do

    end

    it 'has a many-to-many relationship called editors to users' do

    end
  end

  describe EditableModel.new do
    it 'is a DataMapper resource' do

    end

    it 'belongs_to a User "creator"' do

    end

    it 'has n User "editors"' do

    end

    it 'can be saved by its creator' do

    end

    it 'can be saved by an editor' do

    end

    it 'can only be saved by a user' do

    end

    it 'cannot be saved by a user who is not a creator or editor' do

    end

    it 'cannot have an explicit editor who is also creator' do

    end
  end
end
