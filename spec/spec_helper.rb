require 'bundler/setup'
require 'drowsy'
require 'webmock'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) { WebMock.disable_net_connect!(allow_localhost: true) }
  config.after(:all) { WebMock.allow_net_connect! }
  config.after(:each) { WebMock.reset! }
end
