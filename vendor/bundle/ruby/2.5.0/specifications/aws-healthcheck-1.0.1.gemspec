# -*- encoding: utf-8 -*-
# stub: aws-healthcheck 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "aws-healthcheck".freeze
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Logan Serman".freeze]
  s.date = "2015-02-03"
  s.description = "Mounts a Rack app at /healthcheck that returns a 200 for AWS load balancers".freeze
  s.email = ["loganserman@gmail.com".freeze]
  s.homepage = "http://github.com/lserman/healthcheck".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "Mounts a Rack app at /healthcheck that returns a 200 for AWS load balancers".freeze

  s.installed_by_version = "2.7.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 3.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 3.0"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 3.0"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
