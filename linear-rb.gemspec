Gem::Specification.new do |spec|
  spec.name          = "linear-rb"
  spec.version       = "0.3.0"
  spec.authors       = ["Dave Kinkead"]
  spec.email         = ["hi@davekinkead.com"]

  spec.summary       = "Ruby CLI wrapper for Linear GraphQL API"
  spec.description   = "Efficient command-line interface for interacting with Linear's GraphQL API"
  spec.homepage      = "https://github.com/davekinkead/linear-rb"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.files         = Dir["lib/**/*", "bin/*", "README.md"]
  spec.bindir        = "bin"
  spec.executables   = ["linear"]
  spec.require_paths = ["lib"]

  # No runtime dependencies - uses stdlib only

  spec.add_development_dependency "rspec", "~> 3.13"
end
