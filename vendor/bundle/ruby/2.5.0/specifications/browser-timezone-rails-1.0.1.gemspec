# -*- encoding: utf-8 -*-
# stub: browser-timezone-rails 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "browser-timezone-rails".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["kbaum".freeze]
  s.date = "2016-08-23"
  s.description = "The browser timezone is set on the Time#zone".freeze
  s.email = ["karl.baum@gmail.com".freeze]
  s.homepage = "https://github.com/kbaum/browser-timezone-rails".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Sets the browser timezone within rails".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 3.1"])
      s.add_runtime_dependency(%q<js_cookie_rails>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<jstz-rails3-plus>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
      s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_development_dependency(%q<launchy>.freeze, [">= 0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 3.1"])
      s.add_dependency(%q<js_cookie_rails>.freeze, [">= 0"])
      s.add_dependency(%q<jstz-rails3-plus>.freeze, [">= 0"])
      s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
      s.add_dependency(%q<capybara>.freeze, [">= 0"])
      s.add_dependency(%q<launchy>.freeze, [">= 0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 3.1"])
    s.add_dependency(%q<js_cookie_rails>.freeze, [">= 0"])
    s.add_dependency(%q<jstz-rails3-plus>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_dependency(%q<capybara>.freeze, [">= 0"])
    s.add_dependency(%q<launchy>.freeze, [">= 0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
