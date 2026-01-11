Pod::Spec.new do |s|
  s.name             = 'checkout_sheet_kit_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Shopify Checkout Sheet Kit'
  s.description      = <<-DESC
A Flutter plugin that integrates Shopify's native checkout-sheet-kit
SDKs for Android and iOS, providing a seamless checkout experience.
                       DESC
  s.homepage         = 'https://github.com/Shopify/checkout-sheet-kit-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Shopify' => 'mobile@shopify.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ShopifyCheckoutSheetKit', '~> 3.0'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
