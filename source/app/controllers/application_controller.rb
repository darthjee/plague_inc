# frozen_string_literal: true

# Base controller
class ApplicationController < ActionController::Base
  include Azeroth::Resourceable

  helper Magicka::Helper

  def forbidden
    head :forbidden
  end
end
