# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'swee/version'

Gem::Specification.new do |spec|
  spec.name          = "swee"
  spec.version       = Swee::VERSION
  spec.authors       = ["yoshikizh"]
  spec.email         = ["177365340@qq.com"]
  spec.summary       = %q{一个简单的基于ruby的web框架}
  spec.description   = %q{自带轻量级的http服务器}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files        = Dir['bin/**/*', 'lib/**/{*,.[a-z]*}'] + Dir["ext/**/*.{h,c,rb,rl}"]
  spec.extensions   = Dir["ext/**/extconf.rb"]
  spec.bindir       = 'bin'
  spec.executables  = ['swee']
  spec.require_paths = ["lib"]

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_dependency "bundler", "~> 1.7"
  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "rack"
  spec.add_dependency "daemons",      '~> 1.0', '>= 1.0.9'
  spec.add_dependency "eventmachine", '~> 1.0.4'
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "minitest"

end
