Pod::Spec.new do |s|
s.name = "PangeaMediaPicker"
s.version = "1.0.6"
s.license = "MIT"
s.summary = "A picture browser on iOS.This is a picture check control that supports the screen, and it supports picture preview, check, screen display."
s.homepage = "https://github.com/PangeaSocialNetwork/PangeaGallery"
s.authors = {"RogerLi" => "roger@pangea.com" }
s.source = { :git => "https://github.com/PangeaSocialNetwork/PangeaGallery.git", :tag => "v#{s.version}"}
s.requires_arc = true
s.ios.deployment_target = "9.0"
s.source_files = "PangeaMediaPicker/ImagePicker/*.swift"
s.resources = ["PangeaMediaPicker/ImagePicker/ImagePicker.storyboard","PangeaMediaPicker/*.xcassets"]
end
