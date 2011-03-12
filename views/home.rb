module SimpleScraper
  class Application
    module Views
      class Home < Layout
        def user_name
          @creator.name
        end

        # TODO currently using the same format as links, which is not quite accurate.  Destroying one of these would destroy an actual resource.
        def relationships
          @creator.class.relationships.collect do |name, relationship|
            {
              :name => name.to_s,
              :location => relationship.target_model.location,
              :related_model => relationship.target_model.raw_name,
              :related_model_location => relationship.target_model.location,
              :resources => @creator.send(name).to_a do |resource|
                {
                  :name => resource.full_name,
                  :resource_location => resource.location,
                  :relationship_location => resource.location
                }
              end
            }
          end
        end
      end
    end
  end
end
