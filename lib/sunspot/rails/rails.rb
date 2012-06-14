require 'sunspot'

module Sunspot
  module Rails

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Sunspot::Rails::Configuration.new
    end

  end


end
