
Pod::Spec.new do |s|

  s.name         = "JWPickerView"
  s.version      = "1.0.0"
  s.summary      = "PickerView for ios"
  s.homepage     = "https://github.com/Javen-fly/JWPickerView"
  s.license      = "MIT"
  s.author       = { "Javenfly" => "960838547@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Javen-fly/JWPickerView.git", :tag => "1.0.0" }
  s.source_files = "JWPickerView", "JWPickerView/**/*.{h,m}"
  s.framework    = "UIKit"

end
