# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Graph::Plotter do
  let(:graph) { create(:simulation_graph) }
  let(:simulations_size) { 1 }
  let(:days)             { 20 }
  let(:simulations) do
    create_list(:simulation, simulations_size)
  end

  before do
    simulations.each do |simulation|
      contagion = simulation.contagion
      group = contagion.groups.first
      days.times.each do |day|
        instant = create(:contagion_instant, contagion: contagion, day: day)
        day.times do |d|
          create(
            :contagion_population, days: d, instant: instant, group: group, state: :dead,
            size: 10 * d
          )
        end
      end
    end

    simulations.each do |simulation|
      create(:simulation_graph_plot, graph: graph, simulation: simulation)
    end
  end

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
