require 'rubygems'
require 'active_support'
require 'active_resource'

# Ruby lib for working with the Mingle API's XML interface.
# You should set the authentication using your login
# credentials with HTTP Basic Authentication.

# This library is a small wrapper around the REST interface

module MingleAPI
  class Error < StandardError; end
  class << self
    attr_accessor :username, :password, :host_format, :account_format, :domain_format, :protocol

    #Sets up basic authentication credentials for all the resources.
    def authenticate(server, port, username, login)
      @server    = server
      @port      = port
      @username  = username
      @password  = login
      self::Base.user = username
      self::Base.password = login

      resources.each do |klass|
        klass.site = klass.site_format % (host_format % [protocol, account_format % [username, login], domain_format % [server, "#{port}"]])
      end
    end

    def resources
      @resources ||= []
    end
  end

  self.host_format    = '%s://%s@%s/api/v1'
  self.account_format = '%s:%s'
  self.domain_format  = '%s:%s'
  self.protocol       = 'http'

  class Base < ActiveResource::Base
    self.format = :xml
    def self.inherited(base)
      MingleAPI.resources << base
      class << base
        attr_accessor :site_format
      end  
      base.site_format = '%s'
      super
    end
  end

  class Project < Base
    def tickets(options = {})
      Ticket.find(:all, :params => options.update(:identifier => identifier))
    end
    
    def id
      @attributes['id']
    end

    def identifier
      @attributes['identifier']
    end
  end

  class Card < Base
  end
end
