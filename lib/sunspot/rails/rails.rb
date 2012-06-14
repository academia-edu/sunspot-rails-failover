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
    end

    def master_core1_config(sunspot_rails_configuration)
    end

    def slave_core0_config(sunspot_rails_configuration)
    end

    def slave_core1_config(sunspot_rails_configuration)
    end

  end
end
