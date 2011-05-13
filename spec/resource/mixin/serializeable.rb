require 'spec/resource/mixin'

require 'json'
require 'jsonschema'

module MicroScraper::Resource::Mixin::Serializeable
  it_should_behave_like 'resource mixin'
  
  describe 'serializeable resource' do
    describe 'instance' do
      subject { instance }

      describe '#to_json' do
        instance.to_json.should be_a(String)

        it 'should return a json object' do
          JSON.parse(instance.to_json).should be_a(Hash)
        end
      end
    end

    describe 'collection' do
      subject { collection }

      describe '#to_json' do
        collection.to_json.should be_a(String)
        
        it 'should return a json array' do
          JSON.parse(collection.to_json).should be_a(Array)
        end
      end
    end

    describe 'model' do
      subject { model }
      
      describe :fixtures do
        subject { fixtures }
        it { should be_an(Array) }
        it 'is all strings' do
          should all_be { |fixture| fixture.class == String }
        end
        
      end
      
      describe :json_schema do
        subject { instance.json_schema }
        it { should be_a(Hash) }
      end
      
      describe '#from_json' do
        model.fixtures.each do |fixture|
          expect {
            model.from_json(fixture)
          }.to be_an(Array)
        end
      end
    end
  end
end
