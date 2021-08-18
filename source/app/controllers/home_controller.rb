# frozen_string_literal: true

# Contreller used to show home page
class HomeController < ApplicationController
  include OnePageApplication

  def show
    respond_to do |format|
      format.json { render json: summary }
      format.html { render :show }
    end
  end

  private

  def summary
    Simulation.group(:status).count
  end
end
