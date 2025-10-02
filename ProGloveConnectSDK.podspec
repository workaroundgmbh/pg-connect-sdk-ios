sdkVersion = "2.7.2"
sdkSha256 = "3d7d949eb079269d40948f5ac8b92800b5c41cb4d60ae97f12e043a34572e7de"

Pod::Spec.new do |s|
  s.name         = "ProGloveConnectSDK"
  s.version      = sdkVersion
  s.summary      = "Connect SDK allows you to easily add support for the barcode scanner to your App"
  s.description  = <<-DESC
Connect SDK allows you to easily add support for the barcode scanner to your App!
                   DESC
  s.license = { :file => 'LICENSE', :type => 'ProGlove' }
  s.homepage     = "https://proglove.com/"
  s.author             = { "Workaround GmbH" => "service@proglove.de" }
  s.ios.deployment_target = "13.0"
  s.swift_version = "5.0"
  s.frameworks = 'CoreBluetooth'

  s.source = { :http => "https://dl.cloudsmith.io/QQ43WPa2Y7VlFUM3/proglove/markconnectiossdk-prod/raw/names/ConnectSDK-#{sdkVersion}-cocoapods/versions/#{sdkVersion}/ConnectSDK-#{sdkVersion}-cocoapods.zip?accept_eula=8",
               :sha256 => sdkSha256,
               :type => "zip" }

  s.dependency 'iOSMcuManagerLibrary', '~> 1.6.0'

  s.ios.vendored_frameworks = 'ConnectSDK.xcframework',
  'OpenSSL.xcframework',
  'AWSMobileClientXCF.xcframework',
  'AWSCore.xcframework',
  'AWSAuthCore.xcframework',
  'AWSCognitoIdentityProvider.xcframework',
  'AWSCognitoIdentityProviderASF.xcframework',
  'AWSIoT.xcframework'
end
