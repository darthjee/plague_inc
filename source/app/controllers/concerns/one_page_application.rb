# frozen_string_literal: true

# Concern for all controllers that will act in single page application
#
# Requests that arrive are splitted by format and ajax parameter
# - json : process the request (create, update, or fetch) returning a json
# - html : splitted by the presence of ajax parameter
#   - false : redirect to /#path
#     so it is dealt with inside the angular application
#     eg: +GET /simulations+, redirects to +GET /#simulations+
#   - true : returns just the inner HTML template
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
