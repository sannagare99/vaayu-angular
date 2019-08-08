# -*- encoding: utf-8 -*-
# stub: secure_headers 5.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "secure_headers".freeze
  s.version = "5.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Neil Matatall".freeze]
  s.date = "2017-12-05"
  s.description = "Manages application of security headers with many safe defaults.".freeze
  s.email = ["neil.matatall@gmail.com".freeze]
  s.homepage = "https://github.com/twitter/secureheaders".freeze
  s.licenses = ["Apache Public License 2.0".freeze]
  s.post_install_message = "\n**********\n:wave: secure_headers 5.0 introduces a lot of breaking changes (in the name of security!). It's highly likely you will need to update your secure_headers cookie configuration to avoid breaking things. See the upgrade guide for details: https://github.com/twitter/secureheaders/blob/master/docs/upgrading-to-5-0.md\n**********\n\n".freeze
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Add easily configured security headers to responses including content-security-policy, x-frame-options, strict-transport-security, etc.".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<useragent>.freeze, [">= 0.15.0"])
    else
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<useragent>.freeze, [">= 0.15.0"])
    end
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<useragent>.freeze, [">= 0.15.0"])
  end
end
