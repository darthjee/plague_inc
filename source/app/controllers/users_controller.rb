# frozen_string_literal: true

class UsersController < ApplicationController
  include OnePageApplication

  resource_for :user
end
