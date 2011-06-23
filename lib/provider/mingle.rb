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
      if auth.server.blank? and auth.login.blank? and auth.password.blank?
        raise "Please provide server, login and password"
      end
      MingleAPI.authenticate(auth.server, auth.login, auth.password)
    end
      # declare needed overloaded methods here
    def valid?
      begin
        PROJECT_API.find(:first)
        true
      rescue
        false
      end
    end
    
  end
end


