# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Graph::Plotter do
  let(:graph) { create(:simulation_graph) }

  describe '.process' do
    let(:folder) { Settings.tmp_plot_folder }
    let(:output) { "#{folder}/#{output_file}" }
    let(:output_file) { 'file.png' }

    context 'when folder does not exist' do
      before do
        FileUtils.rm_rf(folder)
      end

      it 'creates folder' do
        expect { described_class.process(graph) }
          .to change { Dir[folder].size }.by(1)
      end

      it 'creates image' do
        expect { described_class.process(graph, output: output) }
          .to change { File.exists?(output) }
          .from(false).to(true)
      end

      context 'when passing a file path' do
        let(:folder) { '/tmp/folder' }

        it do
          expect { described_class.process(graph, output: output) }
            .to change { Dir[folder].size }.by(1)
        end

        it 'creates image' do
          expect { described_class.process(graph, output: output) }
            .to change { File.exists?(output) }
            .from(false).to(true)
        end
      end
    end
  end
end
