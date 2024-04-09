#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mirrorfly_uikit_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mirrorfly_uikit_plugin'
  s.version          = '0.0.12'
  s.summary          = 'A Mirrorfly Flutter UIKIT Plugin'
  s.description      = 'A Mirrorfly Flutter UIKIT plugin to Experience an outstanding real time messaging solution. The powerful communication that adds an extra mileage to build your chat app.'

  s.homepage         = 'https://www.mirrorfly.com/docs/uikit/flutter/quick-start/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CONTUS TECH' => 'manivendhan.m@contus.in' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.1'
#   s.dependency 'Socket.IO-Client-Swift', '15.2.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
