module Sunspot
  module SessionProxy
    class AbstractSessionProxy
      class <<self
        def delegate_multi(*args)
          options = Util.extract_options_from(args)
          delegates = options[:to]
          args.each do |method|
            module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
              def #{method}(*args, &block)
                #{delegates}.each do |delegate|
                  send(delegate).#{method}(*args, &block)
                end
              end
            RUBY
          end
        end
      end
    end
  end
end
