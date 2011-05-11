require 'spec/resource/mixin'
require 'lib/resource/user'

module MicroScraper::Resource::Mixin
  shared_examples_for 'editable resource' do
    it_should_behave_like 'resource mixin'
    
    let(:user_model) { MicroScraper::Resource::User }
    let(:generate_user) { user_model.new }
    let(:creator) { generate_user }
    let(:editors) { reps.times.collect { generate_user } }
    let(:rando)   { generate_user }

    around(:each) do |test|
      resource.creator = creator
      resource.editors << editors
      test.run
    end
    
    describe 'editable resource' do
      subject { resource }
      
      describe :creator do
        subject { resource.creator }
        should be_a(user_model)
      end
      
      describe '#creator=' do
        it 'raises an exception when the creator is reassigned' do
          expect {
            resource.creator = rando
          }.to raise_error
        end
      end
      
      describe '#destroy' do
        it { should_not respond_to(:destroy) }
      end
      
      describe :editors do
        subject { resource.editors }
        
        it { should eq(editors) }
        
        it 'raises an exception when the creator is added as another editor' do
          expect {
            resource.editors << creator
            creator.save(resource)
          }.to raise_error
        end
      end

      describe '#save' do
        it { should_not respond_to(:save) }
      end
      
      describe 'saving the editable' do
        it 'can be saved by its creator' do
          expect { creator.save(resource) }.to_not raise_error
        end
        
        it 'can be saved by its editors' do
          editors.each do |editor|
            expect { editor.save(resource) }.to_not raise_error
          end
        end
        
        it 'raises a SecurityError when someone random tries to save it' do
          expect { rando.save(resource) }.to raise_error { |error|
            error.should be_a(SecurityError)
          }
        end
      end
      
      describe 'destroying the editable' do
        it 'can be destroyed by its creator' do
          expect { creator.destroy(resource) }.to_not raise_error
        end
        
        it 'raises a SecurityError when an editor tries to destroy it' do
          editors.each do |editor|
            expect { editor.save(resource) }.to raise_error { |error|
              error.should be_a(SecurityError)
            }
          end
        end

        it 'raises a SecurityError when someone random tries to destroy it' do
          expect { rando.destroy(resource) }.to raise_error { |error|
            error.should be_a(SecurityError)
          end
        end
      end
    end
  end
end
