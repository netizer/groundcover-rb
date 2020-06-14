Gem::Specification.new do |s|
  s.name = "groundcover"
  s.authors = ["Krzysiek Heród"]
  s.licenses = ["MIT"]
  s.homepage = "https://rubygems.org/netizer/groundcover"
  s.version = "0.0.1"
  s.date = "2020-06-13"
  s.summary = "Groundcover frontend to Forest language."
  s.description = "Groundcover is a language that symetrically compiles to Forest."
  s.files = `git ls-files -z`.split("\x0")
  s.require_paths = ["lib"]
end
