module TTFunk
  module WOFF
    class Header
      attr_reader :signature
      attr_reader :flavor
      attr_reader :length
      attr_reader :num_tables
      attr_reader :total_sfnt_size
      attr_reader :major_version
      attr_reader :minor_version
      attr_reader :meta_offset
      attr_reader :meta_length
      attr_reader :meta_orig_length
      attr_reader :priv_offset
      attr_reader :priv_length

      def initialize(io)
        @signature, @flavor, @length, @num_tables, _, @total_sfnt_size,
          @major_version, @minor_version, @meta_offset, @meta_length,
          @meta_orig_length, @priv_offset, @priv_length =
          io.read(44).unpack('N3n2Nn2N5')
      end
    end
  end
end
