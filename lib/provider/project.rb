module TicketMaster::Provider
  module Mingle
    # Project class for ticketmaster-mingle
    #
    #
    class Project < TicketMaster::Provider::Base::Project
      API = MingleAPI::Project # The class to access the api's projects
      # declare needed overloaded methods here
     
      def id
        self[:identifier]
      end

      def initialize(*options)
        super(*options)
      end

      def tickets(*options)
        begin
          if options.first.is_a? Hash
            #options[0].merge!(:params => {:id => id})
            super(*options)
          elsif options.empty?
            tickets = MingleAPI::Card.find(:all, :params => {:identifier => id}).collect { |ticket| TicketMaster::Provider::Mingle::Ticket.new ticket }
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
          copy_ticket = self.ticket!(:title => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end

    end
  end
end


