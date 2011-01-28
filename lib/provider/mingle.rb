module TicketMaster::Provider
  # This is the Mingle Provider for ticketmaster
  module Mingle
    include TicketMaster::Provider::Base
    TICKET_API = MingleAPI::Card # The class to access the api's cards
    PROJECT_API = MingleAPI::Project # The class to access the api's projects
    
    # This is for cases when you want to instantiate using TicketMaster::Provider::Mingle.new(auth)
    def self.new(auth = {})
      TicketMaster.new(:mingle, auth)
    end
    
    # Providers must define an authorize method. This is used to initialize and set authentication
    # parameters to access the API
    
    def authorize(auth = {})
      @authentication ||= TicketMaster::Authenticator.new(auth)
      auth = @authentication
      if auth.server.blank? and auth.port.blank? and auth.name.blank? and auth.login.blank?
        raise "Please provide server, port, name and login"
      end
      MingleAPI.authenticate(auth.server, auth.port, auth.name, auth.login)
    end
      # declare needed overloaded methods here
    
  end
end


