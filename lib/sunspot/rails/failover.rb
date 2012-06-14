require 'sunspot'
require 'sunspot/session_proxy/master_slave_with_failover_session_proxy'
require 'sunspot/rails/failover/exception_handler_adapter'

# Monkey patches
require File.join(File.dirname(__FILE__), 'configuration')
require File.join(File.dirname(__FILE__), 'rails')

require 'pry-nav'

module Sunspot
  module Rails
    module Failover
      class << self
        attr_accessor :exception_handler

        def setup
          master_core0_session = SessionProxy::ThreadLocalSessionProxy.new(master_core0_config)
          master_core1_session = SessionProxy::ThreadLocalSessionProxy.new(master_core1_config)

          slave_core0_session = SessionProxy::ThreadLocalSessionProxy.new(slave_core0_config)
          slave_core1_session = SessionProxy::ThreadLocalSessionProxy.new(slave_core1_config)

          Sunspot.session = if Rails.configuration.is_multicore?
            if Rails.configuration.has_master?
              SessionProxy::MasterSlaveWithFailoverSessionProxy.new(
                SessionProxy::MulticoreSessionProxy.new(master_core0_session, master_core1_session),
                SessionProxy::MulticoreSessionProxy.new(slave_core0_session, slave_core1_session)
              )
            else
              SessionProxy::MulticoreSessionProxy.new(slave_core0_session, slave_core1_session)
            end
          else
            if Rails.configuration.has_master?
              SessionProxy::MasterSlaveWithFailoverSessionProxy.new(
                SessionProxy::ThreadLocalSessionProxy.new(master_config),
                SessionProxy::ThreadLocalSessionProxy.new(slave_config)
              )
            else
              SessionProxy::ThreadLocalSessionProxy.new(slave_config)
            end
          end
        end

        private

        def master_core0_config
          Rails.send :master_core0_config, Rails.configuration
        end

        def master_core1_config
          Rails.send :master_core1_config, Rails.configuration
        end

        def slave_core0_config
          Rails.send :slave_core0_config, Rails.configuration
        end

        def slave_core1_config
          Rails.send :slave_core1_config, Rails.configuration
        end

        def slave_config
          Rails.send :slave_config, Rails.configuration
        end

        def master_config
          Rails.send :master_config, Rails.configuration
        end
      end
    end
  end
end
