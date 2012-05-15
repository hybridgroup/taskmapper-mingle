module TaskMapper::Provider
  module Mingle
    # Ticket class for taskmapper-mingle
    #
    API = MingleAPI::Card

    class Ticket < TaskMapper::Provider::Base::Ticket
      # declare needed overloaded methods herea
      
      def initialize(*object)
        if object.first
          args = object
          object = args.shift
          identifier = args.shift
          @system_data = {:client => object}
          unless object.is_a? Hash
           hash = {:number => object.number,
                   :name => object.name,
                   :description => object.description,
                   :card_type_name => object.card_type.nil? ? "Card" : object.card_type.name,
                   :identifier => identifier,
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

      def self.find_by_id(identifier, number)
        self.search(identifier, {'number' => number}).first
      end

      def self.search(identifier, options = {}, limit = 1000)
        tickets = API.find(:all, :params => {:identifier => identifier}).collect { |ticket| self.new ticket, identifier }
        search_by_attribute(tickets, options, limit)
      end

      def self.find_by_attributes(identifier, attributes = {})
        self.search(identifier, attributes)
      end

      def number
       self[:number].to_i
      end

      def id
        self[:id].to_i
      end

      def name
        self[:name]
      end

      def identifier
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

      def comments(*options)
        begin
          if options.empty?
            comments = MingleAPI::Comment.find(:all, :params => {:identifier => identifier, :number => number}).collect { |comment| TaskMapper::Provider::Mingle::Comment.new comment }
          else
            super(*options)
          end
        rescue
         [] 
        end
      end

      #def comment(*options)

      def comment!(*options)
        options[0].update(:identifier => identifier, :number => number) if options.first.is_a?(Hash)
        Comment.create(*options)
      end
    
    end

  end
end
