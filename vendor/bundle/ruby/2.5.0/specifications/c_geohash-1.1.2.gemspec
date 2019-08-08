# -*- encoding: utf-8 -*-
# stub: c_geohash 1.1.2 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "c_geohash".freeze
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Troy".freeze, "Drew Dara-Abrams".freeze]
  s.date = "2014-11-12"
  s.description = "C_Geohash provides support for manipulating Geohash strings in Ruby. See http://en.wikipedia.org/wiki/Geohash. This is an actively maintained fork of the original http://rubygems.org/gems/geohash".freeze
  s.email = ["dave@popvox.com".freeze, "drew@mapzen.com".freeze]
  s.extensions = ["ext/extconf.rb".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "LICENSE.md".freeze]
  s.files = ["LICENSE.md".freeze, "README.md".freeze, "ext/extconf.rb".freeze]
  s.homepage = "https://github.com/mapzen/geohash".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Geohash library that wraps native C in Ruby".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.4"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.3"])
      s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
    else
      s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.3"])
      s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.3"])
    s.add_dependency(%q<rake-compiler>.freeze, ["~> 0.9"])
  end
end
