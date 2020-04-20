require_relative 'lib/rate_throttle_client/version'

Gem::Specification.new do |spec|
  spec.name          = "rate_throttle_client"
  spec.version       = RateThrottleClient::VERSION
  spec.authors       = ["schneems"]
  spec.email         = ["richard.schneeman+foo@gmail.com"]

  spec.summary       = %q{Don't error, instead, sleep, and retry}
  spec.description   = %q{https://twitter.com/schneems/status/1138899094137651200}
  spec.homepage      = "https://github.com/zombocom/rate_throttle_client"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.2.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zombocom/rate_throttle_client"
  spec.metadata["changelog_uri"] = "https://github.com/zombocom/rate_throttle_client/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "wait_for_it"
  spec.add_development_dependency "m"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "excon"
  spec.add_development_dependency "gruff"
  spec.add_development_dependency "enumerable-statistics"
end
