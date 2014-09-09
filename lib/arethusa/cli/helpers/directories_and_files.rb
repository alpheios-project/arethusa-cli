class Arethusa::CLI
  module Helpers
    module DirectoriesAndFiles
      def plugin_dir(file = '')
        File.join(js_dir, namespaced_name, file)
      end

      def template_dir(file = '')
        File.join(temp_dir, namespaced_name, file)
      end

      def html_template_file
        template_dir("#{name}.html")
      end

      def js_dir(file = '')
        File.join(destination_root, 'app/js', file)
      end

      def temp_dir
        File.join(destination_root, 'app/templates')
      end

      def spec_dir(file = '')
        File.join(destination_root, 'spec', namespaced_name, file)
      end

      def css_dir(file = '')
        File.join(destination_root, 'app/css', file)
      end

      def conf_dir(file = '')
        File.join(destination_root, 'app/static', 'configs', file)
      end

      def dist_dir(file = '')
        File.join(destination_root, 'dist', file)
      end
    end
  end
end
