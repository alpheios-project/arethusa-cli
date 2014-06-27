require 'thor'

module ArethusaPluginGenerator
  class CLI < Thor
    include Thor::Actions

    attr_reader :namespace, :name

    desc 'new', 'Creates a new Arethusa plugin skeleton'
    method_option :namespace, aliases: '-n',
      desc: 'Namespace of the new plugin'
    def new(name)
      @name = name
      @namespace = options[:namespace] || 'arethusa'

      say_status(:success, "Created #{namespaced_name}")
    end

    no_commands do
      def namespaced_name
        [namespace, name].compact.join('.')
      end
    end
  end
end
