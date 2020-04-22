# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Azeroth::Resourceable

  helper FormHelper

  def forbidden
    head :forbidden
  end
end
