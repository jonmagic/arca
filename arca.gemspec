Gem::Specification.new do |spec|
  spec.name          = "arca"
  spec.version       = "2.0.0"
  spec.date          = "2015-07-11"
  spec.summary       = "ActiveRecord callback analyzer"
  spec.description   = "Arca is a callback analyzer for ActiveRecord ideally suited for digging yourself out of callback hell"
  spec.authors       = ["Jonathan Hoyt"]
  spec.email         = "jonmagic@gmail.com"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.homepage      = "https://github.com/jonmagic/arca"
  spec.license       = "MIT"

  spec.add_development_dependency "rake",     "~> 10.4"
  spec.add_development_dependency "minitest", "~> 5.7"
  spec.add_development_dependency "pry", "~> 0.10"
end
