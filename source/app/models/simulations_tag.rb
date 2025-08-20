# frozen_string_literal: true

class SimulationsTag < ApplicationRecord
  belongs_to :simulation
  belongs_to :tag
  has_one :query_tag,
          class_name: 'Tag', foreign_key: 'tag_id',
          validate: false, autosave: false
end
