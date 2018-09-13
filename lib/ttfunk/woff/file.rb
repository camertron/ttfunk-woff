require 'zlib'

module TTFunk
  module WOFF
    class File < ::TTFunk::File
      attr_reader :woff_header

      # override these since we're inheriting from TTFunk::File
      class << self
        def from_dfont(*args)
          raise NotImplementedError, 'WOFFs are not DFonts'
        end

        def from_ttc(*args)
          raise NotImplementedError, 'WOFFs are not font collections'
        end
      end

      def initialize(contents)
        io = StringIO.new(contents)
        @woff_header = Header.new(io)

        tables = {}

        woff_header.num_tables.times do
          tag, offset, comp_length, orig_length, orig_checksum =
            io.read(20).unpack('a4N*')

          tables[tag] = {
            tag: tag,
            checksum: orig_checksum,
            offset: offset,
            length: orig_length,
            comp_length: comp_length
          }
        end

        @contents = WOFFIO.new(io, tables)
      end

      def directory
        @contents.directory
      end
    end
  end
end
