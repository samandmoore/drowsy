
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sleepy/version"

Gem::Specification.new do |spec|
  spec.name          = "sleepy"
  spec.version       = Sleepy::VERSION
  spec.authors       = ["Sam Moore"]
  spec.email         = ["samandmoore@gmail.com"]

  spec.summary       = %q{A library for REST API interactions}
  spec.description   = %q{A library for REST API interactions}
  spec.homepage      = "https://github.com/samandmoore/sleepy"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = ''
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel"
  spec.add_dependency "activesupport"
  spec.add_dependency "faraday", "> 0.13"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "multi_json"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "webmock", "~> 2.0"
  spec.add_development_dependency "sinatra", ">= 1.4"
  spec.add_development_dependency "sinatra-contrib", ">= 1.4"
end
