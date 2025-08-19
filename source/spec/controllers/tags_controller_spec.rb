# frozen_string_literal: true

require 'spec_helper'

describe TagsController do
  let(:expected_json) do
    decorator_class.new(expected_object).to_json
  end
  let(:decorator_class) { Tag::Decorator }

  describe 'GET index' do
    let(:tags_count) { 1 }
    let(:parameters) { {} }

    render_views

    before { create_list(:tag, tags_count) }

    context 'when requesting json', :not_cached do
      let(:expected_object) { Tag.all }

      before do
        get :index, params: parameters.merge(format: :json)
      end

      it { expect(response).to be_successful }

      it 'returns tags serialized' do
        expect(response.body).to eq(expected_json)
      end

      it 'adds page header' do
        expect(response.headers['page']).to eq(1)
      end

      it 'adds pages header' do
        expect(response.headers['pages']).to eq(1)
      end

      it 'adds per_page header' do
        expect(response.headers['per_page']).to eq(20)
      end

      context 'when there are too many tags' do
        let(:tags_count) { 41 }
        let(:expected_object) { Tag.limit(20) }

        it { expect(response).to be_successful }

        it 'returns tags serialized' do
          expect(response.body).to eq(expected_json)
        end

        it 'adds page header' do
          expect(response.headers['page']).to eq(1)
        end

        it 'adds pages header' do
          expect(response.headers['pages']).to eq(3)
        end

        it 'adds per_page header' do
          expect(response.headers['per_page']).to eq(20)
        end
      end

      context 'when requesting last page' do
        let(:tags_count) { 41 }
        let(:expected_object) { Tag.offset(40) }
        let(:parameters) { { page: 3 } }

        it { expect(response).to be_successful }

        it 'returns tags serialized' do
          expect(response.body).to eq(expected_json)
        end

        it 'adds page header' do
          expect(response.headers['page']).to eq(3)
        end

        it 'adds pages header' do
          expect(response.headers['pages']).to eq(3)
        end

        it 'adds per_page header' do
          expect(response.headers['per_page']).to eq(20)
        end
      end

      context 'when requesting with name filters' do
        let(:parameters) { { filter: { name: 'epidemic' } } }
        let!(:expected_object) do
          create_list(:tag, tags_count, name: 'epidemic')
        end

        before do
          create_list(:tag, tags_count, name: 'pandemic')
          get :index, params: parameters.merge(format: :json)
        end

        it { expect(response).to be_successful }

        it 'returns filtered tags serialized' do
          expect(response.body).to eq(decorator_class.new(expected_object).to_json)
        end
      end
    end
  end
end