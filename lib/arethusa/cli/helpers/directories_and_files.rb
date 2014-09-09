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

      def create_module
        template('templates/module.tt', js_dir("#{namespaced_name}.js"))
      end

      def create_service
        template('templates/service.tt', plugin_dir("#{name}.js"))
      end

      def create_html_template
        template('templates/html_template.tt', html_template_file)
      end

      def create_spec_file
        template('templates/plugin_spec.tt', spec_dir("#{name}_spec.js"))
      end
    end
  end
end
