require 'thor'

class Arethusa::CLI
  class Generator < Subcommand
    as_subcommand :generate

    def self.source_root
      File.dirname(__FILE__)
    end

    include Thor::Actions

    desc 'plugin NAME', 'Creates a new Arethusa plugin skeleton'
    method_option :namespace, aliases: '-n', default: 'arethusa',
      desc: 'Namespace of the new plugin'
    method_option :commit, type: :boolean, aliases: '-c',
      desc: 'Commit the skeleton with git'
    def plugin(name)
      @name = name
      @namespace = options[:namespace]

      create_directories
      create_files

      try('add to Gruntfile', :add_to_gruntfile)
      try('add module to index.html', :add_to_index)

      commit_changes if options[:commit]

      puts
      say_status(:success, "Created #{namespaced_name}")
      give_conf_instructions
    end

    desc 'spec NAME', 'Generates a new spec file for an Arethusa plugin'
    method_option :namespace, aliases: '-n', default: 'arethusa',
      desc: 'Namespace of the new plugin'
    method_option :commit, type: :boolean, aliases: '-c',
      desc: 'Commit the skeleton with git'
    def spec(name)
      @name = name
      @namespace = options[:namespace]

      empty_directory(spec_dir)
      create_spec

      commit_changes if options[:commit]
      say_status(:success, "Created spec file for #{namespaced_name}")
    end

    no_commands do
      include Helpers::NameHandler
      include Helpers::DirectoriesAndFiles

      def try(message, method)
        puts
        say_status('trying', "to #{message}...", :yellow)
        send(method)
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

      def add_to_gruntfile
        insert_into_file(gruntfile, after: /var arethusaModules.*?\n/, force: false) do
          %[  "#{namespaced_name}",\n]
        end
      end

      def gruntfile
        File.join(destination_root, 'Gruntfile.js')
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

 "#{name(true)}" : {
   "name" : "#{name(true)}",
   "template" : "#{html_template_file.slice(/template.*/)}"
 }
        EOF
        puts text.lines.map { |line| "\t#{line}" }.join
      end

      def commit_changes(spec = false)
        sp = spec ? "spec " : ""

        message = %{"Add #{sp}skeleton for #{namespaced_name}"}
        `git add -A`
        `git commit -m #{message}`
        sha = `git rev-parse --short HEAD`.chomp
        puts
        say_status(:commited, %(#{sha} #{message}))
      end
    end
  end
end
