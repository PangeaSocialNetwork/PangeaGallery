Pod::Spec.new do |s|
  s.name         = "PangeaMediaPicker"
  s.version      = "0.1"
  s.summary      = "Alternative UIImagePickerController , You can pick multiple photos and videos."
  s.author       = { "RogerLi" => "roger@pangea.com" }
  s.homepage     = "https://github.com/PangeaSocialNetwork/PangeaGallery"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.platform     = :ios , '9.0'
  s.source       = { :git => "https://github.com/PangeaSocialNetwork/PangeaGallery.git", :tag => "0.1" }
  s.requires_arc = true
  s.source_files = "PangeaMediaPicker/ImagePicker"
  s.resources = ["PangeaMediaPicker/ImagePicker/*.{storyboard}","PangeaMediaPicker/*.xcassets"]
  s.public_header_files = "PangeaMediaPicker/ImagePicker/*.{swift}"
  s.ios.frameworks = "UIKit" , "Photos"
  
end
