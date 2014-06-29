class Arethusa::CLI
  class Subcommand < Thor
    def self.as_subcommand(subcommand)
      namespace(subcommand)

      def self.banner(command, namespace = nil, subcommand = false)
        "#{basename} #{@namespace} #{command.usage}"
      end
    end
  end
end
