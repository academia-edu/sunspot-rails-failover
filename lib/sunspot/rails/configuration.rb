require 'erb'

module Sunspot
  module Rails
    class Configuration
      attr_writer :user_configuration

      def method_missing(method_id, *arguments, &block)
        if method_id.to_s =~ /^(?:master_|slave_)?([\w]+)_path$/
          self.class.send :define_method, method_id do
            unless instance_variable_defined?("@#{method_id}")
              path = if has_master?
                user_configuration_from_key('master_solr', "#{$1}_path")
              else
                user_configuration_from_key('solr', "#{$1}_path")
              end
              instance_variable_set("@#{method_id}", path)
            end
          end
          self.send(method_id)
        else
          super
        end
      end

      def respond_to?(method_id, include_private = false)
        if method_id.to_s =~ /^(?:master_|slave_)?([\w]+)_path$/
          true
        else
          super
        end
      end

      # config/sunspot.yml multicore setting enables multicore support
      def is_multicore?
        @is_multicore = !!user_configuration_from_key('multicore')
      end

    end
  end
end
