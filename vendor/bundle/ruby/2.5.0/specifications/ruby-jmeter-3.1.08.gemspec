# -*- encoding: utf-8 -*-
# stub: ruby-jmeter 3.1.08 ruby lib

Gem::Specification.new do |s|
  s.name = "ruby-jmeter".freeze
  s.version = "3.1.08"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tim Koopmans".freeze]
  s.date = "2017-09-25"
  s.description = "Ruby based DSL for writing JMeter test plans".freeze
  s.email = ["support@flood.io".freeze]
  s.executables = ["flood".freeze]
  s.files = ["bin/flood".freeze]
  s.homepage = "http://flood-io.github.io/ruby-jmeter/".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Ruby based DSL for writing JMeter test plans".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rest-client>.freeze, [">= 0"])
      s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>.freeze, [">= 0"])
    s.add_dependency(%q<nokogiri>.freeze, [">= 0"])
  end
end
