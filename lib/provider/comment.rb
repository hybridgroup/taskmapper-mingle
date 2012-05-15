module TaskMapper::Provider
  module Mingle
    # The comment class for taskmapper-mingle
    #
    # Do any mapping between TaskMapper and your system's comment model here
    # versions of the ticket.
    #
    class Comment < TaskMapper::Provider::Base::Comment
    API = MingleAPI::Comment # The class to access the api's comments
      # declare needed overloaded methods here
      
      def initialize(*object)
        if object.first
          object = object.first
          @system_data = {:client => object}
          unless object.is_a? Hash
            hash = {:content => object.content,
                    :created_at => object.created_at,
                    :created_by => object.created_by,
                    :ticket_id => object.prefix_options[:number],
                    :project_id => object.prefix_options[:identifier]}
          else
            hash = object
          end
          super hash
        end
      end

      def created_by
        self[:created_by]
      end
      
      def created_at
        self[:created_at]
      end

      def project_id
        self[:identifier]
      end

      def ticket_id
        self[:number]
      end

    end
  end
end
