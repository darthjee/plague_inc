# frozen_string_literal: true

module FormHelper
  class Element
    def self.render(*args)
      new(*args).render
    end

    def render
      renderer.render partial: template, locals: locals
    end

    private

    attr_reader :renderer

    def initialize(renderer:, **_args)
      @renderer = renderer
    end
  end
end
