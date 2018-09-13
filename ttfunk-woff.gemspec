$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ttfunk/woff/version'

Gem::Specification.new do |s|
  s.name     = 'ttfunk-woff'
  s.version  = ::TTFunk::WOFF::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/camertron'

  s.description = s.summary = 'WOFF support for the TTFunk font library.'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency 'ttfunk', '~> 1.5'

  s.add_development_dependency 'rake', '~> 12'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rubocop', '~> 0.46'

  s.require_path = 'lib'
  s.files = Dir[
    '{lib,spec}/**/*', 'Gemfile', 'README.md',
    'Rakefile', 'ttfunk-woff.gemspec'
  ]
end
