require 'dm-core'
require 'editable'
require 'testable'
require 'regexp'

module MicroScraper
  module Resources

    # A Parser links a regular expression pattern with its replacement.
    module Parser
      def self.included(base)
        base.class_eval do
          include Resource
          include Editable
          include Testable

          has 0..1, :searches_with, 'Regexp'
          has 0..1, :tested_by,     'Regexp'

          property :replacement, Text, :required => true, :default => '$0'
          
          visible :searches_with, :tested_by
          test    :searches_with, :tested_by
        end
      end
    end
    
    class OneToOneParser
      include Parser

      property :match_number, Integer, :required => true, :default => 0
    end

    class OneToManyParser
      include Parser
    end
  end
end
