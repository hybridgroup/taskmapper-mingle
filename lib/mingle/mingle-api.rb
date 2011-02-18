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
    #attr_accessor :username, :password, :host_format, :account_format, :domain_format, :protocol

    #Sets up basic authentication credentials for all the resources.
    def authenticate(server, login, password)
      @server    = server
      @username  = login
      @password  = password
      self::Base.user = login
      self::Base.password = password

      resources.each do |klass|
        klass.site = klass.site_format % "http://#{login}:#{password}@#{server}/api/v2"
      end
    end

    def resources
      @resources ||= []
    end
  end

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

    def exists?(identifier, options = {})
      self.class.find(id)
      true
    rescue ActiveResource::ResourceNotFound, ActiveResource::ResourceGone
       false
    end
    
    def new?
      !self.exists?(id)
    end

    def element_path(options = nil)
       self.class.element_path(self.identifier, options)
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
        unless value.nil?
          case key 
          when 'card_type'
            if value.is_a? Hash
              name = value[:name]
            else
              name = value.name
            end
            val << "card[card_type_name]=#{URI.escape name}"
          when 'properties' 
            value.each {|property| 
              val << "card[properties][][name]=#{URI.escape property[0]}
                      &card[properties][][value]=#{URI.escape property[1]}"} rescue NoMethodError
          else
            val << "card[#{URI.escape key.to_s}]=#{URI.escape value.to_s}" rescue nil
          end
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

    def id
      @attributes['id']
    end

    def name
      @attributes['name']
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

    def card_type
      @attributes['card_type']
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
