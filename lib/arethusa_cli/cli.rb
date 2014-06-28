require 'thor'

module ArethusaCLI
  class CLI < Thor
    require 'arethusa_cli/generator'

    register(Generator, Generator.namespace, "#{Generator.namespace} [ACTION]", 'Generates Arethusa files. Call "arethusa generate" to learn more')
  end
end
