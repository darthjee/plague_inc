# frozen_string_literal: true

class LoginController < ApplicationController
  include OnePageApplication
  include LoggedUser

  protect_from_forgery except: %i[create logoff]

  before_action :save_session, only: :create
  before_action :check_logged!, only: :check

  def create
    render json: Session::Decorator.new(logged_session)
  end

  def check
    render json: Session::Decorator.new(logged_session)
  end

  def logoff
    destroy_session
  end

  private

  def user
    @user ||= User.login(**login_params)
  end

  def login_params
    params.require(:login).permit(:login, :password)
          .to_h.symbolize_keys
  end
end
