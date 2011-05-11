require 'spec/spec_helper'
require 'spec/resource'

# All resource mixins should behave like this.
module MicroScraper::Resource::Mixin
  shared_examples_for 'resource mixin' do
    it_should_behave_like 'resource'
  end
end
