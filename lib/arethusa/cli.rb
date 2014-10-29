require 'thor'
require 'json'

module Arethusa
  class CLI < Thor
    require 'arethusa/cli/version'
    require 'arethusa/cli/helpers/name_handler'
    require 'arethusa/cli/helpers/directories_and_files'
    require 'arethusa/cli/subcommand'

    require 'arethusa/cli/generator'
    require 'arethusa/cli/transformer'

    include Thor::Actions

    def self.source_root
      File.join(File.dirname(__FILE__), 'cli')
    end

    register(Generator, Generator.namespace, "#{Generator.namespace} [ACTION]", 'Generates Arethusa files. Call "arethusa generate" to learn more')
    register(Transformer, Transformer.namespace, "#{Transformer.namespace} [ACTION]", 'Tranforms Alpheios conf files. Call "arethusa transform" to learn more')

    desc 'build', 'Creates a tar archive to be used for deployment'
    method_option :minify, aliases: '-m', type: :boolean, default: true,
      desc: 'Minifies Arethusa before building'
    def build
      minify if options[:minify]
      empty_directory('deployment')
      @filename = "#{tar_name}#{ending}"
      create_tgz
      say_status(:built, archive_path)
    end

    desc 'deploy ADDRESS DIRECTORY', 'Deploys an Arethusa archive through ssh'
    long_desc <<-EOF
Uses ssh to deploy Arethus on a remote server.

By default a new Arethusa archive file will get created in the process
(overridden by -f), which will be transferred through ssh to its remote
location, where the files are decompressed.

A regular ssh connection is used. If you need to specify additional options
to the ssh command  (like using a specific identity file), use -o and
pass them as a string. Here's a rather complex usage example:

arethusa deploy user@hostname /var/www -f arethusa-1.0.0.tgz -o "-i key.pem"
EOF
    method_option :options, aliases: '-o',
      desc: 'Options to pass to the ssh command'
    method_option :file, aliases: '-f',
      desc: 'Archive file to use - builds a new one by default'
    method_option :small, aliases: '-s', type: :boolean, default: false,
      desc: 'Deploys only Arethusa files without third party code'
    method_option :minify, aliases: '-m', type: :boolean, default: true,
      desc: 'Minifies Arethusa before building'
    def deploy(address, directory)
      @address = address
      @directory = directory
      @ssh_options = options[:options]
      @archive = options[:file]

      @small = options[:small]

      minify if options[:minify] &! @archive
      execute
      say_status(:deployed, "at #{@address} - #{@directory}")
    end

    desc 'merge FILE', 'Merge Arethusa configuration files'
    method_option :base_path, aliases: '-b',
      desc: 'Base path to conf files to be included'
    method_option :minify, aliases: '-m',
      desc: 'Print the resulting JSON minified'
    def merge(file)
      @conf = read_conf(file)
      @conf_dir = options[:base_path] || config_dir
      traverse_and_include(@conf)

      if options[:minify]
        puts @conf.to_json
      else
        puts JSON.pretty_generate(@conf, indent: '  ')
      end
    end

    desc 'init NAMESPACE NAME', 'Initializes a new git repo for plugin development'
    def init(namespace, name)
      @name = name
      @namespace = namespace

      inside namespaced_name do
        init_git
        create_folder_hierarchy
        create_templates
        initial_commit
        install
      end
    end

    no_commands do
      include Helpers::NameHandler
      include Helpers::DirectoriesAndFiles

      def init_git
        if `git init`
          say_status(:success, "Initialized new repo in #{namespaced_name}")
        end
      end

      def initial_commit
        `git add -A`
        `git commit -m 'Initial commit'`
      end

      def create_folder_hierarchy
        dirs = [
          plugin_dir, template_dir, template_dir('compiled'),
          css_dir, conf_dir, dist_dir, dist_dir('configs')
        ]
        dirs.each { |dir| empty_directory(dir) }
      end

      def create_templates
        create_module
        create_service
        create_html_template
        create_spec
        create_scss
        create_gitignore
        create_jshintrc
        create_package
        create_bower
        create_gruntfile
        create_index_file
        create_conf_file
      end

      def install
        `npm install && bower install && gem install sass -v 3.3.14`

        # We have to minify Arethusa by hand for now - this won't be needed
        # at a later stage.
        inside 'bower_components/arethusa' do
          `npm install && bower install`
          `grunt version`
          `grunt minify:all`
        end
      end

      def minify
        if system('bower install && grunt clean version minify:all')
          say_status(:success, 'minified Arethusa')
        else
          say_status(:error, 'minification failed')
          exit
        end
      end

      # For deploy command
      def execute
        `#{archive_to_use} | #{ssh} #{decompress}`
      end

      def compress
        "tar -zc #{folders_to_deploy.join(' ')}"
      end

      def archive_to_use
        @archive ? "cat #{@archive}" : compress
      end

      def ssh
        "ssh #{@ssh_options} #{@address}"
      end

      def decompress
        "tar -zxC #{@directory}"
      end

      # For build command
      def create_tgz
        `tar -zcf #{archive_path} #{folders_to_deploy.join(' ')}`
      end

      def folders_to_deploy
        if @small
          %w{ app dist favicon.ico }
        else
          %w{ app bower_components dist vendor favicon.ico }
        end
      end

      def archive_path
        "deployment/#{@filename}"
      end

      def tar_name
        [tar_namespace, timestamp, git_branch, commit_sha].join('-')
      end

      def ending
        '.tgz'
      end

      def tar_namespace
        'arethusa'
      end

      def git_branch
        `git rev-parse --abbrev-ref HEAD`.strip
      end

      def timestamp
        Time.now.to_i
      end

      def commit_sha
        `git rev-parse --short HEAD`.strip
      end

      # methods for merging
      def config_dir
        "app/static/configs"
      end

      def traverse_and_include(conf)
        inside @conf_dir do
          traverse(conf)
        end
      end

      def traverse(conf)
        clone = conf.clone
        clone.each do |key, value|
          if value.is_a?(Hash)
            traverse(conf[key])
          elsif key == '@include'
            additional_conf = read_conf(value)
            conf.delete(key)
            if additional_conf
              conf.merge!(additional_conf)
              traverse(additional_conf)
            end
          end
        end
      end

      def read_conf(path)
        begin
          JSON.parse(File.read(path))
        rescue
          nil
        end
      end
    end
  end
end
