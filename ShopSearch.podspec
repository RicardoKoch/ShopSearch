#
# Be sure to run `pod lib lint ShopSearch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ShopSearch"
  s.version          = "1.1.21"
  s.summary          = "Cocoapods component for searching and scraping all google shopping catalog"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Cocoapods component for searching and scraping all google shopping catalog.
Easily integrate with any iOS app to get products information, compare prices and much more.
DESC

  s.homepage         = "https://github.com/RicardoKoch/ShopSearch"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ricardo Koch" => "ricardo@ricardokoch.com" }
  s.source           = { :git => "https://github.com/RicardoKoch/ShopSearch.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'ShopSearch/**/*.{h,m,swift}'
  #s.resource_bundles = {
  #  'ShopSearch' => ['ShopSearch/Assets/*.png']
  #}

  # s.public_header_files = 'ShopSearch/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'hpple'
end
