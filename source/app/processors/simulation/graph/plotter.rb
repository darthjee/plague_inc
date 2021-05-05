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
      end

      private

      attr_reader :graph

      def output
        @output ||= "#{Settings.tmp_plot_folder}/plot-#{graph.id}-#{Random.rand(1000)}.png"
      end

      def folder
        @folder ||= output.gsub(/\/[^\/]*$/, "")
      end

      def plot_file
        ::Gnuplot.open do |gp|
          Gnuplot::Plot.new(gp) do |plot|
            setup_plot(plot)

            plot.data << Gnuplot::DataSet.new('x') do |ds|
              ds.with = "lines"
            end
          end
        end
      end

      def setup_plot(plot)
        plot.set :term, :png
        plot.output output
        plot.title graph.title if graph.title
      end
    end
  end
end
