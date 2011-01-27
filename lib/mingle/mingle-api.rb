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

    #Sets up basic authentication credentials for all the resources.
    def authenticate(name, login)
      @user      = name
      @password  = login
      self::Base.user = name
      self::Base.password = login
    end

    def resources
      @resources ||= []
    end
  end

  class Base < ActiveResource::Base
    self.site = ""
    self.format = :xml
    def self.inherited(base)
      MingleAPI.resources << base
      super
    end
  end
