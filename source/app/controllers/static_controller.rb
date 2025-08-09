# frozen_string_literal: true

class StaticController < ApplicationController
  include OnePageApplication

  def forbidden; end
end
