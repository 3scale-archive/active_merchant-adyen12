lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_merchant/adyen12/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_merchant-adyen12'
  spec.version       = ActiveMerchant::Adyen12::VERSION
  spec.authors       = ['Hery Ramihajamalala']
  spec.email         = ['hramihaj@redhat.com']

  spec.summary       = 'Adyen v12 active_merchant gateway with recurring payments.'
  spec.description   = 'This is another Adyen gateway for active_merchant using the v12 of their API.'
  spec.homepage      = 'https://github.com/activemerchant/active_merchant'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activemerchant', '~> 1.77.0'

  # I would love to do this kind of thing but sadly it is chicken-egg problem
  # activemerchant = Gem::Specification.find_by_name('activemerchant')
  # activemerchant.development_dependencies.each do |dep|
  #   spec.add_development_dependency dep.name, dep.requirement
  # end
  spec.add_development_dependency('rake')
  spec.add_development_dependency('test-unit', '~> 3')
  spec.add_development_dependency('mocha', '~> 1')
  spec.add_development_dependency('thor')
end
