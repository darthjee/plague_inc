# frozen_string_literal: true

require 'spec_helper'

fdescribe Simulation::Graph::Plotter do
  let(:graph) { create(:simulation_graph) }
  let(:simulations_size) { 1 }
  let(:days)             { 20 }

  let(:simulations) do
    create_list(:simulation, simulations_size)
  end

  let(:function) do
    Danica.build(:day, :days) { (day - days) * 10 }
  end

  let(:fixture_path) do
    'spec/support/fixtures/dead_graph.png'
  end

  let(:fixture_file) { File.open(fixture_path, "r") }

  before do
    simulations.each do |simulation|
      contagion = simulation.contagion

      days.times.each do |day|
        create(:contagion_instant, contagion: contagion, day: day)
      end

      create(
        :simulation_graph_plot,
        label: "Dead",
        graph: graph,
        simulation: simulation,
        function: function
      )
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

      it 'creates an image' do
        expect { described_class.process(graph) }
          .to change { Dir["#{folder}/*.png"].size }.by(1)
      end

      it 'returns the output path' do
        regexp = "^#{Settings.tmp_plot_folder}/plot-#{graph.id}-\\d{1,3}.png$"
        expect(described_class.process(graph))
          .to match(Regexp.new(regexp))
      end

      it 'creates the image' do
        expect(File.exists?(described_class.process(graph)))
          .to be_truthy
      end

      it 'create the right image' do
        expect(File.read(described_class.process(graph)))
          .to eq(fixture_file.read)
      end

      context 'when passing a file path' do
        let(:folder) { '/tmp/folder' }

        it do
          expect { described_class.process(graph, output: output) }
            .to change { Dir[folder].size }.by(1)
        end

        it 'creates an image' do
          expect { described_class.process(graph, output: output) }
            .to change { Dir["#{folder}/*.png"].size }.by(1)
        end

        it 'creates the image' do
          expect(File.exists?(described_class.process(graph, output: output)))
            .to be_truthy
        end

        it 'create the right image' do
          expect(File.read(described_class.process(graph, output: output)))
            .to eq(fixture_file.read)
        end
      end
    end

    context 'when folder does exist' do
      before do
        FileUtils.mkdir_p(folder)
      end

      it 'does not create folder' do
        expect { described_class.process(graph) }
          .not_to change { Dir[folder].size }
      end

      it 'creates an image' do
        expect { described_class.process(graph) }
          .to change { Dir["#{folder}/*.png"].size }.by(1)
      end

      it 'returns the output path' do
        regexp = "^#{Settings.tmp_plot_folder}/plot-#{graph.id}-\\d{1,3}.png$"
        expect(described_class.process(graph))
          .to match(Regexp.new(regexp))
      end

      it 'creates the image' do
        expect(File.exists?(described_class.process(graph)))
          .to be_truthy
      end

      it 'create the right image' do
        expect(File.read(described_class.process(graph)))
          .to eq(fixture_file.read)
      end
    end

    context 'when file already exist exist' do
      before do
        FileUtils.mkdir_p(folder)
        File.open(output, "w") { |f| f.write("content") }
      end

      it 'does not create folder' do
        expect { described_class.process(graph, output: output) }
          .not_to change { Dir[folder].size }
      end

      it 'updates the image' do
        expect { described_class.process(graph, output: output) }
          .to change { File.read(output) }
          .to(fixture_file.read)
      end
    end
  end
end
