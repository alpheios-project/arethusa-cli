require 'thor'

module ArethusaCLI
  class CLI < Thor
    require 'arethusa_cli/generate'

    register(Generate, 'generate', 'generate ACTION', 'Generates Arethusa files. Call "arethusa generate" to learn more')
  end
end
