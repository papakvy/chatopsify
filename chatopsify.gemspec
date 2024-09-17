# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/chatopsify/version'

Gem::Specification.new do |spec|
  spec.name          = 'chatopsify'
  spec.version       = Chatopsify::VERSION
  spec.authors       = ['phunt']
  spec.email         = ['phunt@runsystem.net']

  spec.summary       = 'Publish deployment notifications to ChatOps via the API'
  spec.description   = 'Publish deployment notifications to ChatOps via the API'
  spec.homepage      = 'https://github.com/papakvy/chatopsify'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6'

  # spec.metadata['allowed_push_host'] = 'TODO: Set to your gem server 'https://example.com''
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/papakvy/chatopsify'
  spec.metadata['changelog_uri'] = 'https://github.com/papakvy/chatopsify/blob/master/CHANGELOG.md'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem

  spec.add_dependency 'capistrano', '~> 3.2', '>= 3.2.0'
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '~> 1'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
