module TaskMapper::Provider
  module Mingle
    # Project class for taskmapper-mingle
    #
    #
    class Project < TaskMapper::Provider::Base::Project
      API = MingleAPI::Project # The class to access the api's projects
      # declare needed overloaded methods here
     
      def id
        self[:identifier]
      end

      def initialize(*options)
        @system_data ||= {}
        @cache ||= {}
        first = options.first 
        case first 
        when Hash 
          super first.to_hash
        else
          @system_data[:client] = first
          super first.attributes
        end
      end

      def tickets(*options)
        begin
          if options.first.is_a? Hash
            #options[0].merge!(:params => {:id => id})
            super(*options)
          elsif options.empty?
            tickets = MingleAPI::Card.find(:all, :params => {:identifier => id}).collect { |ticket| TaskMapper::Provider::Mingle::Ticket.new ticket }
          else
            super(*options)
          end
        rescue
          []
        end
      end

      def ticket!(*options)
        options[0].merge!(:identifier => id) if options.first.is_a?(Hash)
        provider_parent(self.class)::Ticket.create(*options)
      end

      # copy from this.copy(that) copies that into this
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:name => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:content => comment.body)
            sleep 1
          end
        end
      end

    end
  end
end


