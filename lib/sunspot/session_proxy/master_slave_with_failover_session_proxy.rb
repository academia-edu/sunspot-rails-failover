module Sunspot
  module SessionProxy
    class MasterSlaveWithFailoverSessionProxy < MasterSlaveSessionProxy
      attr_accessor :exception

      def commit
        with_exception_handling do
          # Don't commit
          # master_session.commit
        end
      end

      def search(*types, &block)
        begin
          Timeout.timeout(0.01) do
            TCPSocket.new(slave_session.config.solr.url[7..-11], 'echo')
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
  end
end
