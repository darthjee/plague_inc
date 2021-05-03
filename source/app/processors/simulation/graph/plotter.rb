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
            plot.set :term, :png
            plot.output output

            plot.data << Gnuplot::DataSet.new('x') do |ds|
              ds.with = "lines"
              ds.linewidth = 4
            end
          end
        end
      end
    end
  end
end
