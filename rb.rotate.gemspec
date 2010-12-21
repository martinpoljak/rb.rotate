# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rb.rotate}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Martin Kozák"]
  s.date = %q{2010-12-21}
  s.default_executable = %q{rb.rotate}
  s.email = %q{martinkozak@martinkozak.net}
  s.executables = ["rb.rotate"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/rb.rotate",
    "lib/rb.rotate.rb",
    "lib/rb.rotate/configuration.rb",
    "lib/rb.rotate/directory.rb",
    "lib/rb.rotate/dispatcher.rb",
    "lib/rb.rotate/file.rb",
    "lib/rb.rotate/hook.rb",
    "lib/rb.rotate/install/defaults.yaml.initial",
    "lib/rb.rotate/install/rotate.yaml.initial",
    "lib/rb.rotate/log.rb",
    "lib/rb.rotate/mail.rb",
    "lib/rb.rotate/reader.rb",
    "lib/rb.rotate/state.rb",
    "lib/rb.rotate/state/archive.rb",
    "lib/rb.rotate/state/file.rb",
    "lib/rb.rotate/storage.rb",
    "lib/rb.rotate/storage/entry.rb",
    "lib/rb.rotate/storage/item.rb"
  ]
  s.homepage = %q{http://github.com/martinkozak/rb.rotate}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{some text}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pony>, [">= 1.1"])
      s.add_runtime_dependency(%q<sys-uname>, [">= 0.8.5"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
    else
      s.add_dependency(%q<pony>, [">= 1.1"])
      s.add_dependency(%q<sys-uname>, [">= 0.8.5"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    end
  else
    s.add_dependency(%q<pony>, [">= 1.1"])
    s.add_dependency(%q<sys-uname>, [">= 0.8.5"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
  end
end

