# frozen_string_literal: true

require 'spec_helper'

describe Tag, type: :model do
  describe '#save' do
    subject(:tag) { build(:tag, name: name) }
    let(:name)    { 'My tagName' }

    it do
      expect { tag.tap(&:save).reload }
        .to change(tag, :name)
        .to('my tagname')
    end
  end
end
