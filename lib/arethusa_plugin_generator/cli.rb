require 'thor'

module ArethusaPluginGenerator
  class CLI < Thor
    include Thor::Actions

    attr_reader :namespace, :name

    def self.source_root
      File.dirname(__FILE__)
    end

    desc 'new', 'Creates a new Arethusa plugin skeleton'
    method_option :namespace, aliases: '-n',
      desc: 'Namespace of the new plugin'
    def new(name)
      @name = name
      @namespace = options[:namespace] || 'arethusa'

      create_directories
      create_html_template

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

      def create_html_template
        template('templates/html_template.tt', template_dir("#{name}.html"))
      end

      def plugin_dir(file = '')
        File.join(js_dir, namespaced_name, file)
      end

      def template_dir(file = '')
        File.join(temp_dir, namespaced_name, file)
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
