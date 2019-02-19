Gem::Specification.new do |s|
  s.name = "omniauth-alephx"
  s.version = "0.1.32"
  s.require_paths = ["lib"]
  s.authors = ["Nicolas Franck"]
  s.date = "2019-02-19"
  s.description = "omniauth strategy for authenticating against AlephX Service"
  s.email = "nicolas.franck@ugent.be"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/omniauth-alephx.rb",
    "lib/omniauth-alephx/version.rb",
    "lib/omniauth/strategies/alephx.rb",
    "omniauth-alephx.gemspec"
  ]
  s.homepage = "http://github.com/nicolasfranck/omniauth-alephx"
  s.licenses = ["MIT"]
  s.summary = "omniauth strategy for authenticating against AlephX Service"
  s.add_dependency('omniauth','1.3.2')
  s.add_dependency('xml-simple','1.1.5')
end

