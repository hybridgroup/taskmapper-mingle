module TicketMaster::Provider
  module Mingle
    # Ticket class for ticketmaster-mingle
    #
    API = MingleAPI::Card

    class Ticket < TicketMaster::Provider::Base::Ticket
      # declare needed overloaded methods herea
      
      def initialize(*object)
        if object.first
          args = object
          object = args.shift
          project_id = args.shift
          @system_data = {:client => object}
          unless object.is_a? Hash
           hash = {:number => object.number,
                   :name => object.name,
                   :description => object.description,
                   :card_type_name => object.card_type.name,
                   :identifier => project_id,
                   :created_on => object.created_on,
                   :modified_on => object.modified_on,
                   :properties => object.properties}
          else
            hash = object
          end
          super hash
        end
      end

      def self.create(*options)
        card = API.new(*options)
        ticket = self.new card
        card.save
        ticket
      end

      def self.find_by_id(project_id, ticket_number)
        self.search(project_id, {'number' => ticket_number}).first
      end

      def self.search(project_id, options = {}, limit = 1000)
        tickets = API.find(:all, :params => {:identifier => project_id}).collect { |ticket| self.new ticket, project_id }
        search_by_attribute(tickets, options, limit)
      end

      def self.find_by_attributes(project_id, attributes = {})
        self.search(project_id, attributes)
      end

      def number
       self[:number].to_i
      end

      def project_id
        self[:identifier]
      end

      def title
        self[:name]
      end

      def description
        self[:description]
      end

      def status
        self.properties[1].value
      end


      
    end
  end
end
