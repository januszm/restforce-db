module Restforce

  module DB

    # Restforce::DB::Model is a helper module which attaches some special
    # DSL-style methods to an ActiveRecord class, allowing for easier mapping
    # of the ActiveRecord class to an object type in Salesforce.
    module Model

      # :nodoc:
      def self.included(base)
        base.extend(ClassMethods)
      end

      # :nodoc:
      module ClassMethods

        # Public: Initializes a Restforce::DB::Mapping defining this model's
        # relationship to a Salesforce object type.
        #
        # salesforce_model - A String name of an object type in Salesforce.
        # options          - A Hash of options to pass through to the Mapping.
        #
        # Returns a Restforce::DB::Mapping.
        def sync_with(salesforce_model, **options)
          Mapping.new(self, salesforce_model, options)
        end

      end

    end

  end

end
