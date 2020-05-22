# frozen_string_literal: true

require 'spec_helper'

describe FormHelper::Element do
  subject(:element) { klass.new(renderer: renderer) }

  let(:klass) do
    Class.new(described_class)
  end

  let(:renderer) { double('renderer') }
  let(:template) { 'templates/forms/element' }
  let(:locals)   { {} }

  before do
    klass.send(:default_value, :template, template)

    allow(renderer)
      .to receive(:render)
      .with(partial: template, locals: locals)
  end

  describe '#render' do
    it do
      element.render

      expect(renderer).to have_received(:render)
    end

    context 'when initialized with extra params' do
      subject(:element) do
        klass.new(renderer: renderer, name: 'Name')
      end

      it do
        element.render

        expect(renderer).to have_received(:render)
      end
    end
  end
end
