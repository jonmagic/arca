Gem::Specification.new do |spec|
  spec.name          = "arca"
  spec.version       = "2.3.1"
  spec.date          = "2015-08-07"
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

  spec.add_development_dependency "activerecord",  "~> 7.1"
  spec.add_development_dependency "minitest",      "~> 5.22"
  spec.add_development_dependency "pry",           "~> 0.14"
  spec.add_development_dependency "rake",          "~> 13.2"
end
