# frozen_string_literal: true

module Path
  # class responsigle for handling safe_path url builds
  class SafePath
    attr_reader :controller, :method

    MATCHER = /^(\w*)_safe_path$/.freeze

    def initialize(controller, method)
      @controller = controller
      @method = method
    end

    def call_missing(*args)
      safe_path(*args) if MATCHER =~ method && does_respond_to?
    end

    def does_respond_to?
      controller.respond_to?(path_method) if MATCHER.match?(method)
    end

    private

    def path_method
      @path_method ||= MATCHER.match(method)[1] + '_path'
    end

    def safe_path(*args)
      PathCaller.new(controller, path_method, *args).path
    end
  end
end
