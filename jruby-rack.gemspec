
Gem::Specification.new do |s|
  s.name = 'jruby-rack'
  s.version = '1.0.3.rails3.2'
  s.authors = ["Nick Sieger"]
  s.date = Date.today.to_s
  s.description = %{JRuby-Rack is a combined Java and Ruby library that adapts the Java Servlet API to Rack. For JRuby only.}
  s.summary = %q{Rack adapter for JRuby and Servlet Containers}
  s.email = ["nick@nicksieger.com"]
  s.files = Dir['gem/*'] + %w{jruby-rack.gemspec}
  s.homepage = %q{http://jruby.org}
  s.has_rdoc = false
  s.rubyforge_project = %q{jruby-extras}
end
