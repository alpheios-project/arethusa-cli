require 'thor'

module Arethusa
  class CLI < Thor
    require 'arethusa/cli/version'
    require 'arethusa/cli/subcommand'

    require 'arethusa/cli/generator'

    include Thor::Actions

    register(Generator, Generator.namespace, "#{Generator.namespace} [ACTION]", 'Generates Arethusa files. Call "arethusa generate" to learn more')

    desc 'build', 'Creates a tar archive to be used for deployment'
    def build
      empty_directory('deployment')
      @filename = "#{tar_name}#{ending}"
      create_tgz
      say_status(:built, archive_path)
    end

    no_commands do
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
