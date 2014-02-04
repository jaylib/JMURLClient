Pod::Spec.new do |s|
  s.name         = "JMURLCache"
  s.version      = "1.0.3"
  s.summary      = "A short summary of JMURLCache."
  s.description  = <<-DESC
                    No description placeholder for JMURLCache.
                   DESC
  s.homepage     = "http://www.i-pol.com"
  s.screenshots  = "http://www.i-pol.com", "http://www.i-pol.com"
  s.license      = 'MIT'
  s.author       = { "Josef Materi" => "josef.materi@gmail.com" }
  s.source       = { :git => "https://github.com/jaylib/JMURLCache.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.{h,m}'
  #s.resources = 'Assets'

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  s.dependency 'AFNetworking'
  s.dependency 'Reachability'
end
