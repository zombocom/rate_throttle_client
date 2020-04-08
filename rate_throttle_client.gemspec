require_relative 'lib/rate_throttle_client/version'

Gem::Specification.new do |spec|
  spec.name          = "rate_throttle_client"
  spec.version       = RateThrottleClient::VERSION
  spec.authors       = ["schneems"]
  spec.email         = ["richard.schneeman+foo@gmail.com"]

  spec.summary       = %q{FUCKFUCKFUCK Write a short summary, because RubyGems requires one.}
  spec.description   = %q{FUCKFUCKFUCK Write a longer description or delete this line.}
  # spec.homepage      = "FUCKFUCKFUCK Put your gem's website or public repo URL here."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "FUCKFUCKFUCK Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "FUCKFUCKFUCK Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "FUCKFUCKFUCK Put your gem's CHANGELOG.md URL here."

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
end
