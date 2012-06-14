require 'sunspot'

module Sunspot
  module Rails
    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= Sunspot::Rails::Configuration.new
      end

      private

      def master_core0_config(sunspot_rails_configuration)
        config = Sunspot::Configuration.build
        config.solr.url = URI::HTTP.build(
          :host => sunspot_rails_configuration.master_hostname,
          :port => sunspot_rails_configuration.master_port,
          :path => sunspot_rails_configuration.master_core0_path
        ).to_s
        config.solr.read_timeout = sunspot_rails_configuration.read_timeout
        config.solr.open_timeout = sunspot_rails_configuration.open_timeout
        config
      end

      def master_core1_config(sunspot_rails_configuration)
        config = Sunspot::Configuration.build
        config.solr.url = URI::HTTP.build(
          :host => sunspot_rails_configuration.master_hostname,
          :port => sunspot_rails_configuration.master_port,
          :path => sunspot_rails_configuration.master_core1_path
        ).to_s
        config.solr.read_timeout = sunspot_rails_configuration.read_timeout
        config.solr.open_timeout = sunspot_rails_configuration.open_timeout
        config
      end

      def slave_core0_config(sunspot_rails_configuration)
        config = Sunspot::Configuration.build
        config.solr.url = URI::HTTP.build(
          :host => sunspot_rails_configuration.hostname,
          :port => sunspot_rails_configuration.port,
          :path => sunspot_rails_configuration.core0_path
        ).to_s
        config.solr.read_timeout = sunspot_rails_configuration.read_timeout
        config.solr.open_timeout = sunspot_rails_configuration.open_timeout
        config
      end

      def slave_core1_config(sunspot_rails_configuration)
        config = Sunspot::Configuration.build
        config.solr.url = URI::HTTP.build(
          :host => sunspot_rails_configuration.master_hostname,
          :port => sunspot_rails_configuration.master_port,
          :path => sunspot_rails_configuration.core1_path
        ).to_s
        config.solr.read_timeout = sunspot_rails_configuration.read_timeout
        config.solr.open_timeout = sunspot_rails_configuration.open_timeout
        config
      end
    end
  end
end
