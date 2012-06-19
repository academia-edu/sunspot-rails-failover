module Sunspot
  module SessionProxy
    class MasterSlaveWithFailoverSessionProxy < MasterSlaveSessionProxy
      attr_accessor :exception

      def commit
        with_exception_handling do
          master_session.commit
        end
      end

      def search(*types, &block)
        begin
          Timeout.timeout(0.01) do
            TCPSocket.new(slave_session.config.solr.url[7..-11], slave_session.config.solr.url[-9..-6].to_i)
          end
        rescue
          slave_dead = true
        end

        unless slave_dead
          result = with_exception_handling { slave_session.search(*types, &block) }
        end
        result ||= with_exception_handling { master_session.search(*types, &block) }

        raise(exception) unless result
        result
      end

      private

      def with_exception_handling
        yield
      rescue Exception => exception
        Rails::Failover::ExceptionHandlerAdapter.handle(exception)
        self.exception = exception
        false
      end

    end

    class MulticoreSessionProxy < AbstractSessionProxy

      # Connects to core0 of solr instance
      attr_reader :core0_session

      # Connects to core1 of solr instance
      attr_reader :core1_session

      def initialize(core0_session, core1_session)
        @core0_session, @core1_session = core0_session, core1_session
      end

      def config(delegate = :core0)
        case delegate
        when :core0 then @core0_session.config
        when :core1 then @core1_session.config
        else raise(ArgumentError, "Expected :core0 or :core1")
      end
    end
  end
end
