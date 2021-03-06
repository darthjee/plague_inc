# frozen_string_literal: true

require 'gnuplot'

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    class Plotter
      include ::Processor

      def initialize(graph, output: nil)
        @graph = graph
        @output = output
      end

      def process
        FileUtils.mkdir_p(folder)
        plot_file
        output
      end

      private

      attr_reader :graph

      def output
        @output ||= [
          Settings.tmp_plot_folder,
          "plot-#{graph.id}-#{Random.rand(1000)}.png"
        ].join('/')
      end

      def folder
        @folder ||= output.gsub(%r{/[^/]*$}, '')
      end

      def plot_file
        ::Gnuplot.open do |gp|
          Gnuplot::Plot.new(gp) do |plot|
            setup_plot(plot)

            data_sets.each do |data_set|
              plot.data << data_set
            end
          end
        end
      end

      def setup_plot(plot)
        plot.set :term, :png
        plot.output output
        plot.title graph.title if graph.title
      end

      def data_sets
        graph.plots.map do |plot|
          Gnuplot::DataSet.new(plot.plot_data) do |ds|
            ds.with = 'lines'
            ds.title = plot.label
          end
        end
      end
    end
  end
end
