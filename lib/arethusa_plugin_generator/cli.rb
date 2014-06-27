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

      create_directories

      puts
      say_status(:success, "Created #{namespaced_name}")
    end

    no_commands do
      def namespaced_name
        [namespace, name].compact.join('.')
      end

      DIRECTORIES = %w{ plugin_dir template_dir }
      def create_directories
        DIRECTORIES.each { |dir| empty_directory(send(dir)) }
      end

      def plugin_dir
        File.join(js_dir, namespaced_name)
      end

      def template_dir
        File.join(temp_dir, namespaced_name)
      end

      def js_dir
        File.join(destination_root, 'app/js')
      end

      def temp_dir
        File.join(destination_root, 'app/templates')
      end
    end
  end
end
