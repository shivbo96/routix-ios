Pod::Spec.new do |s|
  s.name             = 'RoutixSDK'
  s.version          = '1.0.0'
  s.summary          = 'Official Routix SDK for iOS. Attribute deep links and track conversion events.'

  s.description      = <<-DESC
The official Routix SDK for iOS. Empower your mobile application with industry-leading attribution, deep linking, and conversion measurement.
                       DESC

  s.homepage         = 'https://routix.link'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Routix Team' => 'info@routix.link' }
  s.source           = { :git => 'https://github.com/shivbo96/routix-ios.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'RoutixSDK/Sources/RoutixSDK/**/*'
  
  # s.resource_bundles = {
  #   'RoutixSDK' => ['RoutixSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
