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
        klass.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      end
    end

    def resources
      @resources ||= []
    end
  end

  self.host_format    = '%s://%s@%s/api/v2'
  self.account_format = '%s:%s'
  self.domain_format  = '%s:%s'
  self.protocol       = 'http'

  class Base < ActiveResource::Base
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

    #begin monkey patches

    def exists?(id, options = {})
      self.class.find(id)
      true
    rescue ActiveResource::ResourceNotFound, ActiveResource::ResourceGone
       false
    end
    
    def new?
      !self.exists?(id)
    end

    def element_path(options = nil)
       self.class.element_path(self.id, options)
    end

    def encode(options={})
       val = []
       attributes.each_pair do |key, value|
         val << "project[#{URI.escape key}]=#{URI.escape value}" rescue nil
       end  
       val.join('&')
    end
   
    def create
        connection.post(collection_path + '?' + encode, nil, self.class.headers).tap do |response|
          self.id = id_from_response(response)
          load_attributes_from_response(response)
        end
    end

    #end monkey patches
 
    def tickets(options = {})
      Card.find(:all, :params => options.update(:identifier => id))
    end
    
    def id
      @attributes['identifier']
    end

  end

  class Card < Base
    self.site_format << '/projects/:identifier/'

    def element_path(options = nil)
      self.class.element_path(self.id, options)
    end

    def encode(options={})
      val = []
      attributes.each_pair do |key, value|
        val << "card[#{URI.escape key}]=#{URI.escape value}" rescue nil
      end
      val.join('&')
    end

    def update
      connection.put(element_path(prefix_options) + '?' + encode, nil, self.class.headers).tap do |response|
        load_attributes_from_response(response)
      end
    end

    def create
      connection.post(collection_path + '?' + encode, nil, self.class.headers).tap do |response|
        self.id = id_from_response(response)
        load_attributes_from_response(response)
      end
    end

  end

end
