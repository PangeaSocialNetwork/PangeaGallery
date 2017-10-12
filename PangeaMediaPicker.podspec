Pod::Spec.new do |s|
s.name = 'PangeaMediaPicker'
s.version = '1.0.0'
s.license = 'MIT'
s.summary = 'A picture browser on iOS.'
s.homepage = 'https://github.com/PangeaSocialNetwork/PangeaGallery'
s.authors = { 'RogerLi' => 'roger@pangea.com' }
s.source = { :git => 'https://github.com/PangeaSocialNetwork/PangeaGallery.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '9.0'
s.source_files = 'PangeaMediaPicker/ImagePicker'
s.resources = ['PangeaMediaPicker/ImagePicker/*.storyboard','PangeaMediaPicker/*.xcassets']
s.public_header_files = 'PangeaMediaPicker/ImagePicker/*.swift'
s.ios.frameworks = 'UIKit' , 'Photos'
end
