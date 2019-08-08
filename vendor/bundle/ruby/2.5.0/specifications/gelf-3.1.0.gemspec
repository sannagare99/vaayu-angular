# -*- encoding: utf-8 -*-
# stub: gelf 3.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "gelf".freeze
  s.version = "3.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alexey Palazhchenko".freeze, "Lennart Koopmann".freeze, "Zac Sprackett".freeze, "Marcus Ilgner".freeze]
  s.date = "2018-09-05"
  s.description = "Library to send GELF messages to Graylog logging server. Supports plain-text, GELF messages and exceptions via UDP and TCP.".freeze
  s.email = "mail@marcusilgner.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.md".freeze]
  s.files = ["LICENSE".freeze, "README.md".freeze]
  s.homepage = "https://github.com/graylog-labs/gelf-rb".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Library to send GELF messages to Graylog logging server.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>.freeze, ["~> 2.11.3"])
      s.add_development_dependency(%q<jeweler>.freeze, ["~> 2.1.1"])
      s.add_development_dependency(%q<rack>.freeze, ["< 2.0"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 1.1.0"])
      s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.2.0"])
      s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
    else
      s.add_dependency(%q<shoulda>.freeze, ["~> 2.11.3"])
      s.add_dependency(%q<jeweler>.freeze, ["~> 2.1.1"])
      s.add_dependency(%q<rack>.freeze, ["< 2.0"])
      s.add_dependency(%q<mocha>.freeze, ["~> 1.1.0"])
      s.add_dependency(%q<test-unit>.freeze, ["~> 3.2.0"])
      s.add_dependency(%q<json>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<shoulda>.freeze, ["~> 2.11.3"])
    s.add_dependency(%q<jeweler>.freeze, ["~> 2.1.1"])
    s.add_dependency(%q<rack>.freeze, ["< 2.0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.1.0"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 3.2.0"])
    s.add_dependency(%q<json>.freeze, [">= 0"])
  end
end
