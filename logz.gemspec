lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logz/version"

Gem::Specification.new do |spec|
  spec.name = "logz"
  spec.version = Logz::VERSION
  spec.authors = ["Ivan Tumanov"]
  spec.email = ["vizakenjack@gmail.com"]
  spec.licenses = ["MIT"]
  spec.summary = %q{Simple and lightweight logger tool}
  spec.description = %q{Output to STDOUT and log file at the same time. Support for multiple log files.}
  spec.homepage = "https://github.com/v1z4/logz"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rainbow", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
