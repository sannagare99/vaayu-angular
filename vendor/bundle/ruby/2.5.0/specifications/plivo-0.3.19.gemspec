# -*- encoding: utf-8 -*-
# stub: plivo 0.3.19 ruby lib
# stub: ext/mkrf_conf.rb

Gem::Specification.new do |s|
  s.name = "plivo".freeze
  s.version = "0.3.19"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Plivo Inc".freeze]
  s.date = "2015-11-25"
  s.description = "A Ruby gem for interacting with the Plivo Cloud Platform".freeze
  s.email = "support@plivo.com".freeze
  s.extensions = ["ext/mkrf_conf.rb".freeze]
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze, "ext/mkrf_conf.rb".freeze]
  s.homepage = "http://www.plivo.com".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "A Ruby gem for communicating with the Plivo Cloud Platform".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>.freeze, [">= 2.1.2"])
      s.add_runtime_dependency(%q<rest-client>.freeze, [">= 1.6.7", "~> 1.6"])
      s.add_runtime_dependency(%q<json>.freeze, [">= 1.6.6", "~> 1.6"])
      s.add_runtime_dependency(%q<htmlentities>.freeze, [">= 4.3.1", "~> 4.3"])
    else
      s.add_dependency(%q<builder>.freeze, [">= 2.1.2"])
      s.add_dependency(%q<rest-client>.freeze, [">= 1.6.7", "~> 1.6"])
      s.add_dependency(%q<json>.freeze, [">= 1.6.6", "~> 1.6"])
      s.add_dependency(%q<htmlentities>.freeze, [">= 4.3.1", "~> 4.3"])
    end
  else
    s.add_dependency(%q<builder>.freeze, [">= 2.1.2"])
    s.add_dependency(%q<rest-client>.freeze, [">= 1.6.7", "~> 1.6"])
    s.add_dependency(%q<json>.freeze, [">= 1.6.6", "~> 1.6"])
    s.add_dependency(%q<htmlentities>.freeze, [">= 4.3.1", "~> 4.3"])
  end
end
