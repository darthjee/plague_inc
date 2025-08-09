# frozen_string_literal: true

module UserRequired
  extend ActiveSupport::Concern

  included do
    include LoggedUser
    include OnePageApplication

    redirection_rule :render_forbidden, :missing_user?
    skip_redirection_rule :render_root, :missing_user?

    delegate :user_required?, to: :class
  end

  class_methods do
    def require_user_for(*actions)
      require_user_actions.merge(actions.map(&:to_sym))
    end

    def require_user_actions
      @require_user_actions ||= Set.new
    end

    def user_required?(action)
      require_user_actions.include?(action.to_sym)
    end
  end

  def render_forbidden
    '#/forbidden'
  end

  def missing_user?
    return false if logged_user
    return false unless user_required?(action_name)

    true
  end
end
