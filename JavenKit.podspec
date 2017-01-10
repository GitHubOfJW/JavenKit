

Pod::Spec.new do |s|

  s.name         = "JavenKit"
  s.version      = "0.0.1"
  s.summary      = "Swift版本 日期选择控制器（2种样式）、 日期选择键盘（10种模式）、自动轮播（UIScrollView）、图片浏览（仿Twitter）、弹出提示（JWAlertController）、加载提示（简介大方）、WebViewController(彩色进度条)、MessageView(消息拖拽效果)"
  s.homepage     = "https://github.com/GitHubOfJW/JavenKit"
  s.license      = "MIT"
  s.author             = { "Javen" => "1284627282@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/GitHubOfJW/JavenKit.git", :tag => "#{s.version}" }
  s.source_files  = "JavenKit","JavenKit/**/*.{swift}"
  s.resources = "JavenKit/images.bundle/*.png"
  s.framework  = "UIKit"
end


