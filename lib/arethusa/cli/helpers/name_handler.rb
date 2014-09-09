class Arethusa::CLI
  module Helpers
    module NameHandler
      def namespaced_name(js = false, no_default = false)
        ns = namespace(js);
        ns = nil if no_default && @namespace == 'arethusa'
        [ns, name(js)].compact.join('.')
      end

      def namespace(js = false)
        js ? to_camelcase(@namespace) : @namespace
      end

      def name(js = false)
        js ? to_camelcase(@name) : @name
      end

      def to_camelcase(str)
        parts = str.split('_')
        first = parts.shift
        "#{first}#{parts.map(&:capitalize).join}"
      end
    end
  end
end
