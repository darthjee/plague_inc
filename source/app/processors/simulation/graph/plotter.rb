# frozen_string_literal: true

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
      end

      private

      attr_reader :graph

      def output
        @output ||= "#{Settings.tmp_plot_folder}/plot-#{graph.id}-#{Random.rand(1000)}.png"
      end

      def folder
        @folder ||= output.gsub(/\/[^\/]*$/, "")
      end

      def plot
        Gnuplot.open do |gp|
          Gnuplot::Plot.new(gp) do |plot|
          end
        end
      end
    end
  end
end
