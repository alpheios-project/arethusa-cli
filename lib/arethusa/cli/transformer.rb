require 'nokogiri'

class Arethusa::CLI
  class Transformer < Subcommand
    as_subcommand :transform

    desc 'relation [FILE]', 'Transforms relation configurations'
    def relation(file)
    end

    no_commands do

    end
  end
end


