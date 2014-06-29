require 'thor'

module Arethusa
  class CLI < Thor
    require 'arethusa/cli/version'
    require 'arethusa/cli/subcommand'

    require 'arethusa/cli/generator'

    include Thor::Actions

    register(Generator, Generator.namespace, "#{Generator.namespace} [ACTION]", 'Generates Arethusa files. Call "arethusa generate" to learn more')

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
    method_option :minify, aliases: '-m', type: :boolean, default: true,
      desc: 'Minifies Arethusa before building'
    def deploy(address, directory)
      @address = address
      @directory = directory
      @ssh_options = options[:options]
      @archive = options[:file]

      minify if options[:minify] &! @archive
      execute
      say_status(:deployed, "at #{@address} - #{@directory}")
    end

    no_commands do
      def minify
        `grunt minify`
        say_status(:success, 'minified Arethusa')
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
        %w{ app bower_components dist vendor }
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
    end
  end
end
