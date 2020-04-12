# frozen_string_literal: true

module Path
  class SafePath
    class PathCaller
      attr_reader :controller, :method, :args

      def initialize(controller, method, args)
        @controller = controller
        @method = method
        @args = args
      end

      def path
        controller_path.tap do |path|
          keys_map.each do |key, key_s|
            regexp = Regexp.new("\\b#{key_s}\\b")
            path.gsub!(regexp, args[key])
          end
        end
      end

      private

      def key_names
        @key_names ||= args.keys.map { |k| "_#{k}" }
      end

      def keys_map
        @keys_map ||= key_names.as_hash(args.keys)
      end

      def controller_path
        @controller_path ||= controller.public_send(method, keys_map)
      end
    end
  end
end
