# frozen_string_literal: true

# Base record class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
