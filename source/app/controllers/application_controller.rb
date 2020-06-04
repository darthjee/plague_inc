# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Azeroth::Resourceable

  helper Magicka::Helper

  def forbidden
    head :forbidden
  end
end
