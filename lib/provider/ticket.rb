module TicketMaster::Provider
  module Mingle
    # Ticket class for ticketmaster-mingle
    #
    
    class Ticket < TicketMaster::Provider::Base::Ticket
      API = MingleAPI::Card # The class to access the api's tickets
      # declare needed overloaded methods herea
      
      def initialize(*object)
        if object.first
          object = object.first
          @system_data = {:client => object}
          unless object.is_a? Hash
           hash = { :number => object.number,
                    :name => object.name,
                    :description => object.description,
                    :card_type => object.card_type.name,
                    :project_id => object.project.identifier,
                    :created_on => object.created_on,
                    :modified_on => object.modified_on}
          else
            hash = object
          end
          super hash
        end
      end

      def id
       self[:number].to_i
      end

      
    end
  end
end
