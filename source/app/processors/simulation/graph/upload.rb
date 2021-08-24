# frozen_string_literal: true

require 'gnuplot'
require 'bcrypt_pbkdf'

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
          GraphSettings.host,
          GraphSettings.username,
          {
            key_data: GraphSettings.key
          }
        ]
      end

      def remote_path
        [GraphSettings.folder, "#{graph_id}#{extension}"].join('/')
      end

      def extension
        File.extname(file_path)
      end
    end
  end
end
