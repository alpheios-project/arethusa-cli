class Arethusa::CLI
  module Helpers
    module DirectoriesAndFiles
      def template_path(name)
        File.join(File.expand_path('../../templates/', __FILE__), name)
      end

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
        File.join(destination_root, 'spec', mod || namespaced_name, file)
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
        template(template_path('module'), js_dir("#{namespaced_name}.js"))
      end

      def create_service
        template(template_path('service'), plugin_dir("#{name}.js"))
      end

      def create_html_template
        template(template_path('html_template'), html_template_file)
      end

      def create_spec
        template(template_path('plugin_spec'), spec_dir("#{name}_spec.js"))
      end

      def create_gitignore
        template(template_path('gitignore'), '.gitignore')
      end

      def create_jshintrc
        template(template_path('jshintrc'), '.jshintrc')
      end

      def create_package
        template(template_path('package'), 'package.json')
      end

      def create_bower
        template(template_path('bower'), 'bower.json')
      end

      def create_gruntfile
        template(template_path('gruntfile'), 'Gruntfile.js')
      end

      def create_scss
        template(template_path('scss'), css_dir("#{namespaced_name}.scss"))
      end

      def create_index_file
        template(template_path('index'), "app/index.html")
      end

      def create_conf_file
        template(template_path('conf'), conf_dir('staging.json'))
      end

      def create_retriever
        template(template_path('retriever'), js_dir(File.join(mod, "#{name}.js")))
      end

      def create_retriever_spec
        template(template_path('retriever_spec'), spec_dir("#{name}_spec.js"))
      end
    end
  end
end
