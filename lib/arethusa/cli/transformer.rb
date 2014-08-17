require 'nokogiri'
require 'json'

class Arethusa::CLI
  class Transformer < Subcommand
    as_subcommand :transform

    desc 'relations [FILE]', 'Transforms relation configurations'
    def relations(file)
      @doc = Nokogiri::XML(open(file))
      @conf = Relations.new

      parse('relation', :add_label)
      parse('subrelation', :add_suffix)

      puts JSON.pretty_generate(@conf, indent: '  ')
    end

    no_commands do
      def parse(type, method)
        @doc.xpath("//xmlns:table[@type = '#{type}']/xmlns:entry").each do |entry|
          short = entry.xpath('./xmlns:tb').text
          next if short == '-' || short.empty?
          long  = entry.xpath('./xmlns:menu').text
          @conf.send(method, stripped(short), stripped(long))
        end
      end

      def stripped(str)
        str.sub(/^_/, '')
      end

      class Relations
        def initialize
          @labels = {}
          @suffixes = {}
        end

        def add_label(short, long)
          @labels[short] = Relation.new(short, long)
        end

        def add_suffix(short, long)
          @suffixes[short] = Relation.new(short, long)
        end

        def to_json(options = {})
          hsh = { relations: { labels: @labels, suffixes: @suffixes } }
          hsh.to_json(options)
        end
      end

      class Relation
        def initialize(short, long)
          @short = short
          @long  = long
        end

        def to_json(options = {})
          { short: @short, long: @long }.to_json(options)
        end
      end
    end
  end
end
