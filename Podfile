# Uncomment the next line to define a global platform for your project
platform :ios, '11.1'
use_frameworks!

target 'curbmap' do
  # Not included : [[Mapbox-iOS-SDK', '~> 3.7'], ['RealmSwift'], ['Instructions', '~> 1.1.0']]
  pod 'OpenLocationCode'
  pod 'Alamofire'
  pod 'AlamofireImage', '~> 3.3'
  pod 'KeychainAccess'
  pod 'RxSwift',    '~> 4.0'
  pod 'RxCocoa',    '~> 4.0'
  pod 'RxCoreLocation', '~> 1.3.0'
  pod 'NVActivityIndicatorView'
  pod 'Mixpanel-swift', :git=> 'https://github.com/mixpanel/mixpanel-swift.git', :branch=> 'swift4'

  
  # Pods for curbmap-ios-mvp

  target 'curbmapTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'curbmapUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
