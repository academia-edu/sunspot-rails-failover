require 'erb'

module Sunspot
  module Rails
    class Configuration
      attr_writer :user_configuration

      def hostname
        unless defined?(@hostname)
          @hostname   = solr_url.host if solr_url
          @hostname ||= user_configuration_from_key('solr', 'hostname')
          @hostname ||= default_hostname
        end
        @hostname
      end

      def port
        unless defined?(@port)
          @port   = solr_url.port if solr_url
          @port ||= user_configuration_from_key('solr', 'port')
          @port ||= default_port
          @port   = @port.to_i
        end
        @port
      end

      def path
        unless defined?(@path)
          @path   = solr_url.path if solr_url
          @path ||= user_configuration_from_key('solr', 'path')
          @path ||= default_path
        end
        @path
      end

      def master_hostname
        binding.pry
        @master_hostname ||= (user_configuration_from_key('master_solr', 'hostname') || hostname)
      end

      def master_port
        @master_port ||= (user_configuration_from_key('master_solr', 'port') || port).to_i
      end

      def master_path
        @master_path ||= (user_configuration_from_key('master_solr', 'path') || path)
      end

      def method_missing(method_id, *arguments, &block)
        if method_id.to_s =~ /^(?:master|slave)_([\w]+)_path$/
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
        if method_id.to_s =~ /^(?:master|slave)_([\w]+)_path$/
          true
        else
          super
        end
      end

      # config/sunspot.yml multicore setting enables multicore support
      def is_multicore?
        @is_multicore = !!user_configuration_from_key('multicore')
      end

      def has_master?
        @has_master = !!user_configuration_from_key('master_solr')
      end

      def log_file
        @log_file ||= (user_configuration_from_key('solr', 'log_file') || default_log_file_location )
      end

      def data_path
        @data_path ||= user_configuration_from_key('solr', 'data_path') || File.join(::Rails.root, 'solr', 'data', ::Rails.env)
      end

      def pid_dir
        @pid_dir ||= user_configuration_from_key('solr', 'pid_dir') || File.join(::Rails.root, 'solr', 'pids', ::Rails.env)
      end


      #
      # The solr home directory. Sunspot::Rails expects this directory
      # to contain a config, data and pids directory. See
      # Sunspot::Rails::Server.bootstrap for more information.
      #
      # ==== Returns
      #
      # String:: solr_home
      #
      def solr_home
        @solr_home ||=
          if user_configuration_from_key('solr', 'solr_home')
            user_configuration_from_key('solr', 'solr_home')
          else
            File.join(::Rails.root, 'solr')
          end
      end

      #
      # Solr start jar
      #
      def solr_jar
        @solr_jar ||= user_configuration_from_key('solr', 'solr_jar')
      end

      #
      # Minimum java heap size for Solr instance
      #
      def min_memory
        @min_memory ||= user_configuration_from_key('solr', 'min_memory')
      end

      #
      # Maximum java heap size for Solr instance
      #
      def max_memory
        @max_memory ||= user_configuration_from_key('solr', 'max_memory')
      end

      #
      # Interface on which to run Solr
      #
      def bind_address
        @bind_address ||= user_configuration_from_key('solr', 'bind_address')
      end

      def read_timeout
        @read_timeout ||= user_configuration_from_key('solr', 'read_timeout')
      end

      def open_timeout
        @open_timeout ||= user_configuration_from_key('solr', 'open_timeout')
      end
    end
  end
end
