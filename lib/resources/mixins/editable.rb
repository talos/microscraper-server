require 'dm-core'
require 'dm-timestamps'

require '/lib/resources/user'

module MicroScraper
  module Resources
    
    # Editable resources belong to a creator.
    # They can only be saved by a creator or an editor.
    module Editable
      def self.included(base)
        base.class_eval do
          include Resource
          
          property :created_at, DateTime, :writer => :private
          property :updated_at, DateTime, :writer => :private
          
          property :description, Text
          
          belongs_to :creator, :model => 'User', :required => true
          property :creator_id, Integer, :required => true, :writer => :private, :unique_index => :uindex
          
          has n, :editors, :model => 'User', :through => Resource
          
          #property :last_editor_id, Integer, :accessor => :private
          has 1, :last_editor, :model => 'User'
          
          validates_with_method :assure_editor_is_not_creator
          
          # Set last_editor to creator by default
          before :valid? do
            if last_editor.nil?
              last_editor = creator
            end
          end
          
          # Destroy links before destroying resource.
          before :destroy do
            model.relationships.each do |r|
              # todo -- do we have to do this meta-check?
              if(send(r.name).has_method?(:intermediaries))
                send(r.name).intermediaries.destroy
              end
            end
          end
          
          orig_save = instance_method :save

          # The resource must be saved by a specific user.
          # @param [MicroScraper::Resources::User] the user who is trying to save
          def save (user)
            if(editable_by? user)
              orig_save
            end
          end
        end
      end

      # Prevent creator from being added to list of editors.
      def assure_editor_is_not_creator
        if editors.include? creator
          [ false, "creator is always an editor" ]
        else
          true
        end
      end
      
      # Can this user edit the resource?
      def editable_by? (user)
        creator == user or editors.include? user
      end
    end
  end
end
    # TODO: does not work with CPK
    # def unlink(relationship_name, link)
    #   relationship = model.relationships[relationship_name.to_sym]
    #   raise DataMapper::UnknownRelationshipError.new unless relationship.class == DataMapper::Associations::ManyToMany::Relationship
    #   raise DataMapper::UnknownRelationshipError.new unless relationship.target_model == link.model
      
    #   send(relationship_name).intermediaries.get([*[key, link.key].flatten], [*[key, link.key].flatten]).destroy
    # end

    #  def full_name
    #   creator.full_name + '/' + title
    # end
     
    # def modify (new_attributes, last_updated_at, editor)
    #   if updated_at != last_updated_at
    #     raise DataMapper::UpdateConflictError.new
    #   end
    #   super new_attributes, last_updated_at, editor
    #   @last_editor = editor
    # end

      # def self.related_model (relationship)
      #   relationships[relationship.to_sym] ? relationships[relationship.to_sym].target_model : nil
      # end
      
      # def self.many_to_many_relationships
      #   relationships.select { |r| r.class == DataMapper::Associations::ManyToMany::Relationship }
      # end


    # Safely change a resource's attributes
    # def modify (new_attributes, last_updated_at, editor)
    #   new_attributes.delete_if do |name, value|
    #     if not attributes.keys.include? name.downcase.to_sym # Delete attributes not specified in the model
    #       true
    #     elsif private_methods.include? name + '=' # Remove private attributes.
    #       true
    #     end
    #   end
    #   self.attributes=(new_attributes)
    # end
    
    # def associations
    #   model.traversable_relationships.collect do |r|
    #     {
    #       :name => r.name,
    #       :size => send(r.name).length,
    #       :model_location => r.target_model.location,
    #       :location => location + '/' + URI.encode(r.name.to_s) + '/',
    #       :collection => send(r.name).collect do |resource|
    #         # Substitute link location for real location
    #         {
    #           :full_name => resource.full_name,
    #           :location => location + '/' + URI.encode(r.name.to_s) + '/' + resource.attribute_get(:id).to_s,
    #           :resource => resource
    #         }
    #       end
    #     }
    #   end
    # end
    
    # def related_resources(prior = [])
    #   resources = []
    #   # scan the traversable relationships
    #   model.traversable_relationships.each do |r|
    #     send(r.name).each do |related_resource|
    #       # make sure not to loop back
    #       if related_resource != self and not prior.include? related_resource
    #         resources << related_resource
    #         resources.push(*related_resource.related_resources(resources))
    #       end
    #     end
    #   end
    
    #   resources
    # end
