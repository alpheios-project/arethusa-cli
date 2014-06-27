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
      create_files

      try('insert module into arethusa', :add_module)
      try('add module to index.html', :add_to_index)

      puts
      say_status(:success, "Created #{namespaced_name}")
      #give_conf_instructions
    end

    no_commands do
      def try(message, method)
        puts
        say_status('trying', "to #{message}...", :yellow)
        send(method)
      end

      def namespaced_name
        [namespace, name].compact.join('.')
      end

      DIRECTORIES = %w{ plugin_dir template_dir }
      def create_directories
        DIRECTORIES.each { |dir| empty_directory(send(dir)) }
      end

      def create_files
        create_module
        create_service
        create_html_template
      end

      def create_module
        template('templates/module.tt', js_dir("#{namespaced_name}.js"))
      end

      def create_service
        template('templates/service.tt', plugin_dir("#{name}.js"))
      end

      def create_html_template
        template('templates/html_template.tt', html_template_file)
      end

      def add_module
        insert_into_file(arethusa_main, before: /\n\]/, force: false) do
          ",\n  '#{namespaced_name}'"
        end
      end

      def arethusa_main
        js_dir('arethusa.js')
      end

      def add_to_index
        insert_into_file(index_file, after: /script.*?core.*?script>\n/) do
          %{  <script src="../dist/#{namespaced_name}.min.js"></script>\n}
        end
      end

      def index_file
        File.join(destination_root, 'app', 'index.html')
      end

      def give_conf_instructions
        text = <<-EOF
Now add your new #{name} plugin to a conf file and add a configuration for it.
It could look like this:

 "#{name}" : {
   "name" : "#{name}",
   "template" : #{html_template_file.slice(/template.*/)}
 }
        EOF
        puts text.lines.map { |line| "\t#{line}" }.join
      end

      def plugin_dir(file = '')
        File.join(js_dir, namespaced_name, file)
      end

      def template_dir(file = '')
        File.join(temp_dir, namespaced_name, file)
      end

      def html_template_file
        template_dir("#{name}.html")
      end

      def js_dir(file = '')
        File.join(destination_root, 'app/js', file)
      end

      def temp_dir
        File.join(destination_root, 'app/templates')
      end
    end
  end
end
