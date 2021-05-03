# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Graph::Plotter do
  let(:graph) { create(:simulation_graph) }

  describe '.process' do
    let(:folder) { Settings.tmp_plot_folder }

    context 'when folder does not exist' do
      before do
        FileUtils.rm_rf(folder)
      end

      it 'creates folder' do
        expect { described_class.process(graph) }
          .to change { Dir[folder].size }.by(1)
      end

      context 'when passing a file path' do
        let(:folder) { '/tmp/folder' }
        let(:output) { "#{folder}/#{output_file}" }
        let(:output_file) { 'file.png' }

        it do
          expect { described_class.process(graph, output: output) }
            .to change { Dir[folder].size }.by(1)
        end
      end
    end
  end
end
