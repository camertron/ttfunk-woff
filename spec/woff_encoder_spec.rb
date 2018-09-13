require 'spec_helper'

describe TTFunk::WOFF::WOFFEncoder do
  subject { described_class.new(sfnt, subset) }

  let(:sfnt_file) { test_font('DejaVuSans') }
  let(:sfnt) { TTFunk::File.open(sfnt_file) }
  let(:subset) do
    TTFunk::Subset::Unicode.new(sfnt).tap do |subset|
      # ASCII lowercase
      (97..122).each { |char| subset.use(char) }
    end
  end

  let(:woff) { TTFunk::WOFF::File.open(StringIO.new(subject.encode)) }

  let(:sfnt_cmap) { sfnt.cmap.unicode.first }
  let(:woff_cmap) { woff.cmap.unicode.first }

  it 'encodes the WOFF header correctly' do
    expect(woff.woff_header.signature).to eq(described_class::WOFF_SIGNATURE)
    expect(woff.woff_header.num_tables).to eq(woff.directory.tables.size)
    expect(woff.woff_header.length).to eq(woff.contents.length)
  end

  it 'calculates the sfnt size correctly' do
    table_length = woff.directory.tables.inject(0) do |sum, table|
      sum + table[:length] + table[:length] % 4
    end

    expect(woff.woff_header.total_sfnt_size).to(
      eq(12 + (woff.directory.tables.size * 16) + table_length)
    )
  end

  it 'encodes the head table correctly' do
    %i(version flags units_per_em x_min y_min x_max y_max).each do |prop|
      expect(woff.header.send(prop)).to eq(sfnt.header.send(prop))
    end
  end

  it 'encodes the glyf table correctly' do
    (97..122).each do |codepoint|
      sfnt_glyph = sfnt.glyph_outlines.for(sfnt_cmap[codepoint])
      woff_glyph = woff.glyph_outlines.for(woff_cmap[codepoint])

      %i(number_of_contours raw x_max x_min y_max y_min).each do |prop|
        expect(woff_glyph.send(prop)).to eq(sfnt_glyph.send(prop))
      end
    end
  end

  it 'encodes the hmtx table correctly' do
    (97..122).each do |codepoint|
      sfnt_metric = sfnt.horizontal_metrics.for(sfnt_cmap[codepoint])
      woff_metric = woff.horizontal_metrics.for(woff_cmap[codepoint])

      %i(advance_width left_side_bearing).each do |prop|
        expect(woff_metric.send(prop)).to eq(sfnt_metric.send(prop))
      end
    end
  end

  it 'encodes the fpgm table correctly' do
    expect(woff.directory.tables['fpgm'][:checksum]).to eq(
      sfnt.directory.tables['fpgm'][:checksum]
    )
  end

  context 'with a CFF charstrings font' do
    let(:sfnt_file) { test_font('Exo-Regular', :otf) }

    it 'encodes charstrings correctly' do
      # @TODO
    end
  end
end
