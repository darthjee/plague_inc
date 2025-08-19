# frozen_string_literal: true

# Controller for listing {Tag}
#
# This controller provides basic listing functionality with filtering support
class TagsController < ApplicationController
  include OnePageApplication

  resource_for :tag,
               only: [:index],
               paginated: true,
               per_page: 20

  private

  def tags
    @tags ||= filter.apply(Tag.all)
  end

  def filter
    Tag::Filter.new(params[:filter])
  end
end
