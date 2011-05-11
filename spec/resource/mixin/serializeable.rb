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
        subject { model.fixtures }
        it { should be_an(Array) }
      end

      describe :json_schema do
        subject { instance.json_schema }
        it { should be_a(Hash) }
      end

      describe '#from_json' do
        json_array = model.fixtures.collect { |fixture| fixture.to_s }.to_json
        expect {
          model.from_json(json_array)
        }.to be_an(Array)
      end
    end
  end
end
