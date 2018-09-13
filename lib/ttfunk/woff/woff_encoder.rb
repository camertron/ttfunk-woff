require 'zlib'

module TTFunk
  module WOFF
    class WOFFEncoder
      WOFF_SIGNATURE = 0x774F4646
      CFF_FLAVOR = 0x4F54544F  # OTTO
      POSTSCRIPT_FLAVOR = 0x00010000

      attr_reader :encoder

      def initialize(original, subset, options = {})
        encoder_class = original.cff.exists? ? TTFunk::OTFEncoder : TTFunk::TTFEncoder
        @encoder = encoder_class.new(original, subset, options)
      end

      def encode
        encoded_sfnt = encoder.encode
        sfnt = TTFunk::File.open(StringIO.new(encoded_sfnt))

        newfont = EncodedString.new
        newfont << woff_header(sfnt)
        newfont << woff_directory(sfnt)

        uncompressed_size = 12 + (16 * sfnt.directory.tables.size)

        optimal_table_order.each do |tag|
          table = sfnt.directory.tables[tag]
          next unless table

          uncompressed_size += table[:length] + table[:length] % 4
          newfont.resolve_placeholder(
            "#{tag}_offset", [newfont.length].pack('N')
          )

          table_data = encoded_sfnt[table[:offset], table[:length]]
          compressed_table_data = compress(table_data)

          if compressed_table_data.length < table_data.length
            table_data = compressed_table_data
          end

          newfont.resolve_placeholder(
            "#{tag}_comp_length", [table_data.length].pack('N')
          )

          newfont << table_data
          newfont.align!(4)
        end

        newfont.resolve_placeholder(
          :total_size, [newfont.length].pack('N')
        )

        newfont.resolve_placeholder(
          :total_sfnt_size, [uncompressed_size].pack('N')
        )

        newfont.string
      end

      private

      def woff_directory(sfnt)
        EncodedString.new do |newfont|
          # Tables are supposed to be listed in ascending order whereas there
          # is a known optimal order for table data.
          sfnt.directory.tables.keys.sort.each do |tag|
            table = sfnt.directory.tables[tag]

            # 4-byte sfnt table identifier.
            newfont << [tag].pack('A4')

            # Offset to the data, from beginning of WOFF file.
            newfont << Placeholder.new("#{tag}_offset", length: 4)

            # Length of the compressed data, excluding padding.
            newfont << Placeholder.new("#{tag}_comp_length", length: 4)

            # 1. Length of the uncompressed table, excluding padding.
            # 2. Checksum of the uncompressed table.
            newfont << [table[:length], table[:checksum]].pack('NN')
          end
        end
      end

      def woff_header(sfnt)
        EncodedString.new do |header|
          # 1. 0x774F4646 'wOFF'
          # 2. The "sfnt version" of the input font.
          header << [WOFF_SIGNATURE, flavor].pack('NN')

          # Total size of the WOFF file.
          header << Placeholder.new(:total_size, length: 4)

          # 1. Number of entries in directory of font tables.
          # 2. Reserved; set to zero.
          header << [sfnt.directory.tables.size, 0].pack('nn')

          # Total size needed for the uncompressed font data, including the sfnt header,
          # directory, and font tables (including padding).
          header << Placeholder.new(:total_sfnt_size, length: 4)

          # 1. Major version of the WOFF file.
          # 2. Minor version of the WOFF file.
          # (both are user-specified and have no bearing on parsing or validation)
          header << [0, 0].pack('nn')

          # 1. Offset to metadata block, from beginning of WOFF file.
          # 2. Length of compressed metadata block.
          # 3. Uncompressed size of metadata block.
          header << [0, 0, 0].pack('NNN')

          # 1. Offset to private data block, from beginning of WOFF file.
          # 2. Length of private data block.
          header << [0, 0].pack('NN')
        end
      end

      def compress(data)
        Zlib::Deflate.deflate(data)
      end

      def flavor
        return CFF_FLAVOR if original.cff.exists?
        POSTSCRIPT_FLAVOR
      end

      def original
        encoder.original
      end

      def optimal_table_order
        encoder.send(:optimal_table_order)
      end
    end
  end
end
