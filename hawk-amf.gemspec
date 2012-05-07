# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hawk-amf}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stephen Augenstein", "David Currin"]
  s.email = ['support@trifectagis.com']
  s.files =`git ls-files`.split("\n")
  s.homepage = "http://trifactagis.com"
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = "A Rails 3 plugin that provides tight rails amf integration"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
