module TTFunk
  module WOFF
    class DirectoryTables
      include Enumerable

      attr_reader :tables

      def initialize
        @tables = []
      end

      def [](tag)
        tables.find { |t| t[:tag] == tag }
      end

      def <<(table)
        @tables << table
      end

      def last
        tables.last
      end

      def include?(tag)
        tables.any? { |table| table[:tag] == tag }
      end

      def size
        tables.size
      end

      def each(&block)
        tables.each(&block)
      end

      def for_offset(offset)
        tables.bsearch do |table|
          if offset >= table[:offset] + table[:length]
            1
          elsif offset < table[:offset]
            -1
          else
            0
          end
        end
      end
    end

    class Directory
      SCALER_TYPE_TRUETYPE = 0x00010000
      SCALER_TYPE_CFF = 0x4F54544F  # OTTO

      attr_reader :tables

      def initialize(orig_tables)
        @tables = DirectoryTables.new

        orig_tables.values
          .sort_by { |t| t[:offset] }
          .each_with_index do |orig_table, idx|
            if idx == 0
              tables << orig_table.merge(
                comp_offset: orig_table[:offset]
              )

              next
            end

            last = tables.last

            tables << orig_table.merge(
              comp_offset: orig_table[:offset],
              offset: last[:offset] + last[:length]
            )
          end
      end

      def table_for(offset)
        tables.for_offset(offset)
      end

      def scaler_type
        return SCALER_TYPE_CFF if tables.include?(TTFunk::Table::Cff::TAG)
        SCALER_TYPE_TRUETYPE
      end
    end
  end
end
