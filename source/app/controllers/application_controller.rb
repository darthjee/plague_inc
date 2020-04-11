# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Azeroth::Resourceable

  def forbidden
    head :forbidden
  end
end
