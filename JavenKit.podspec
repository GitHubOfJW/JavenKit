

Pod::Spec.new do |s|

  s.name         = "JavenKit"
  s.version      = "0.0.7"
  s.summary      = "Swift kit"
  s.homepage     = "https://github.com/GitHubOfJW/JavenKit"
  s.license      = "MIT"
  s.author             = { "Javen" => "1284627282@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/GitHubOfJW/JavenKit.git", :tag => "#{s.version}" }
  s.source_files = "JavenKit","JavenKit/**/*.{swift}"
  s.resources = "JavenKit/images.bundle"
  s.framework  = "UIKit"
end


