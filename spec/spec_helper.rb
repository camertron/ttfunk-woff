require 'ttfunk'
require 'rspec'

require 'ttfunk/woff'
require 'ttfunk/subset'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.include PathHelpers
end
