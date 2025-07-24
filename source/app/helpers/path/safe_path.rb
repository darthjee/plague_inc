# frozen_string_literal: true

module Path
  class SafePath
    attr_reader :controller, :method

    MATCHER = /^(\w*)_safe_path$/

    def initialize(controller, method)
      @controller = controller
      @method = method
    end

    def call_missing(*)
      safe_path(*) if MATCHER =~ method && does_respond_to?
    end

    # rubocop:disable Naming/PredicateName
    def does_respond_to?
      controller.respond_to?(path_method) if MATCHER.match?(method)
    end
    # rubocop:enable Naming/PredicateName

    private

    def path_method
      @path_method ||= "#{MATCHER.match(method)[1]}_path"
    end

    def safe_path(*)
      PathCaller.new(controller, path_method, *).path
    end
  end
end
