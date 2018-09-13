require 'zlib'

module TTFunk
  module WOFF
    class WOFFIO
      attr_reader :io, :directory
      attr_accessor :pos

      def initialize(io, tables)
        @io = io
        @pos = 0
        @uncompressed_tables = {}
        @directory = Directory.new(tables)
      end

      def read(length)
        if (table = directory.table_for(pos))
          table_data = table_data_for(table)
          table_data[pos - table[:offset], length]
        else
          io.seek(pos)
          io.read(length)
        end.tap { @pos += length }
      end

      def seek(offset)
        pos = offset
      end

      def length
        io.length
      end

      private

      def table_data_for(table)
        @uncompressed_tables[table[:tag]] ||= begin
          old_pos = io.pos
          io.seek(table[:comp_offset])
          table_data = io.read(table[:comp_length])
          io.seek(old_pos)

          if table[:comp_length] == table[:length]
            table_data
          else
            Zlib::Inflate.inflate(table_data)
          end
        end
      end
    end
  end
end
