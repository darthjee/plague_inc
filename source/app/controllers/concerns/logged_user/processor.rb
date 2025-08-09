# frozen_string_literal: true

module LoggedUser
  SESSION_KEY = :session

  class Processor
    def initialize(controller)
      @controller = controller
    end

    def login(user)
      @logged_user = user

      signed_cookies[SESSION_KEY] = new_session.id
    end

    def logoff
      session&.update(expiration: 1.second.ago)
      cookies.delete(SESSION_KEY)
    end

    def logged_user
      @logged_user ||= session&.user
    end

    def session
      @session ||= session_from_cookie || session_from_headers
    end

    alias logged_session session

    private

    attr_reader :controller

    def new_session
      @session = logged_user.sessions.create(
        expiration: Settings.session_period.from_now
      )
    end

    def session_from_cookie
      active_sessions.find_by(id: session_id)
    end

    def session_from_headers
      active_sessions.find_by(token:)
    end

    def session_id
      signed_cookies[SESSION_KEY]
    rescue NoMethodError
      nil
    end

    def token
      headers['Authorization']&.gsub(/Bearer */, '')
    end

    def signed_cookies
      @signed_cookies ||= cookies.signed
    end

    def active_sessions
      Session.active
    end

    def cookies
      @cookies ||= controller.send(:cookies)
    end

    def headers
      @headers ||= controller.send(:headers)
    end

    def params
      @params ||= controller.send(:params)
    end
  end
end
