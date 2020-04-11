# frozen_string_literal: true

module OnePageApplication
  extend ActiveSupport::Concern
  include Tarquinn

  included do
    after_action :cache_control

    layout :layout_for_page
    redirection_rule :render_root, :perform_angular_redirect?
    skip_redirection_rule :render_root, :ajax?, :home?
  end

  private

  def render_root
    "##{request.path}"
  end

  def home?
    request.path == '/'
  end

  def ajax?
    params[:ajax]
  end

  def perform_angular_redirect?
    html? && get?
  end

  def html?
    request.format.html?
  end

  def get?
    request.get?
  end

  def layout_for_page
    ajax? ? false : 'application'
  end

  def cache_control
    return unless html?

    headers['Cache-Control'] = "max-age=#{Settings.cache_age}, public"
    request.session_options[:skip] = true
  end
end
