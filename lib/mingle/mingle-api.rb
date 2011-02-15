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
    def authenticate(server, username, login)
      @server    = server
      @username  = username
      @password  = login
      self::Base.user = username
      self::Base.password = login

      resources.each do |klass|
        klass.site = "http://#{username}:#{login}@#{server}"
        #klass.site = klass.site_format % (host_format % [protocol, account_format % [username, login], domain_format % [server, "#{port}"]])
        klass.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      end
    end

    def resources
      @resources ||= []
    end
  end

  #self.host_format    = '%s://%s@%s/api/v2'
  #self.account_format = '%s:%s'
  #self.domain_format  = '%s:%s'
  #self.protocol       = 'http'

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

    #begin monkey patches

    def element_path(options = nil)
      self.class.element_path(self.number, options)
    end

    def encode(options={})
      val = []
      attributes.each_pair do |key, value|
        case key 
        when 'card_type'
          if value.is_a? Hash
            name = value[:name]
         else
            name = value.name
          end
           val << "card[card_type_name]=#{URI.escape name}" rescue nil
        when 'properties' 
          value.each {|property| 
            val << "card[properties][][name]=#{URI.escape property[0]}
                    &card[properties][][value]=#{URI.escape property[1]}"} rescue NoMethodError
        else
          val << "card[#{URI.escape key.to_s}]=#{URI.escape value.to_s}" rescue nil
        end
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
        self.number = id_from_response(response)
        load_attributes_from_response(response)
      end
    end

    #end monkey patches

    def number
      @attributes['number']
    end

    def created_on
      @attributes['created_on']
    end

    def modified_on
      @attributes['modified_on']
    end

    def description
      @attributes['description']
    end

    def card_type_name
      @attributes['card_type_name']
    end

    def properties
      @attributes['properties']
    end

  end

  class Comment < Base
    self.site_format << '/projects/:identifier/cards/:number'

    def create
      connection.post(collection_path + '?' + encode, nil, self.class.headers).tap do |response|
        load_attributes_from_response(response)
      end
    end

    def encode(options={})
      val=[]
      attributes.each_pair do |key, value|
        val << "comment[#{URI.escape key}]=#{URI.escape value}" rescue nil
      end
      val.join('&')
    end

  end

end
