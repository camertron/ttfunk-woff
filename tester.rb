require 'ttfunk'
require 'ttfunk/woff'
require 'ttfunk/subset'
require 'pry-byebug'

font = TTFunk::File.open('/Users/cameron/workspace/lux/app/assets/fonts/NotoSansJP-Medium.ttf')
subset = TTFunk::Subset::Unicode.new(font)

# hiragana
((0x3041..0x3094).to_a + (0x3099..0x309E).to_a).each do |cp|
  subset.use(cp)
end

encoder = TTFunk::WOFF::WOFFEncoder.new(font, subset)
File.open('/Users/cameron/Desktop/NotoSansJP-Medium.woff', 'wb+') do |f|
  f.write(encoder.encode)
end



woff = TTFunk::WOFF::File.open('/Users/cameron/Desktop/NotoSansJP-Medium.woff')
woff_subset = TTFunk::Subset::Unicode.new(woff)

(0x3041..0x3094).each do |cp|
  woff_subset.use(cp)
end

File.open('/Users/cameron/Desktop/NotoSansJP-Medium.ttf', 'wb+') do |f|
  f.write(woff_subset.encode)
end
