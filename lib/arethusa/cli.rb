require 'thor'

module Arethusa
  class CLI < Thor
    require 'arethusa/cli/version'
    require 'arethusa/cli/subcommand'

    require 'arethusa/cli/generator'

    register(Generator, Generator.namespace, "#{Generator.namespace} [ACTION]", 'Generates Arethusa files. Call "arethusa generate" to learn more')
  end
end
