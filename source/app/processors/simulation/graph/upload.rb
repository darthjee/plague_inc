# frozen_string_literal: true

require 'gnuplot'
require 'pry'
require 'pry-nav'

class Simulation < ApplicationRecord
  class Graph < ApplicationRecord
    class Upload
      include ::Processor

      def initialize(graph_id, file_path)
        @graph_id = graph_id
        @file_path = file_path
      end

      def process
        with_connection do |sftp|
          sftp.upload!(file_path, remote_path)
        end
      end
      
      def self.testy
        process(1, '/home/app/app/a.txt')
      rescue => e
        e
      end

      private

      attr_reader :graph_id, :file_path

      def with_connection
        Net::SFTP.start(*connection_args) do |sftp|
          yield(sftp)
        end
      end

      def connection_args
        [
          Settings.graph_host,
          Settings.graph_username,
          {
            password: Settings.graph_password
          }
        ]
      end

      def remote_path
        [Settings.graph_folder, "#{graph_id}#{extension}"].join('/')
      end

      def extension
        File.extname(file_path)
      end
    end
  end
end
