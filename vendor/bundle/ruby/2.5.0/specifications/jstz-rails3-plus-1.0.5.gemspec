# -*- encoding: utf-8 -*-
# stub: jstz-rails3-plus 1.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "jstz-rails3-plus".freeze
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["William Van Etten".freeze]
  s.date = "2015-05-16"
  s.description = "This gem provides jstz.js and for your Rails 3 application.".freeze
  s.email = ["bill@bioteam.net".freeze]
  s.homepage = "http://rubygems.org/gems/jstz-rails".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Use jstz with Rails 3".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.1"])
    else
      s.add_dependency(%q<railties>.freeze, [">= 3.1"])
    end
  else
    s.add_dependency(%q<railties>.freeze, [">= 3.1"])
  end
end
