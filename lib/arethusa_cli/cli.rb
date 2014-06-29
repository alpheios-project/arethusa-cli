require 'thor'
require 'arethusa_cli/subcommand'

module ArethusaCLI
  class CLI < Thor
    require 'arethusa_cli/generator'

    register(Generator, Generator.namespace, "#{Generator.namespace} [ACTION]", 'Generates Arethusa files. Call "arethusa generate" to learn more')
  end
end
