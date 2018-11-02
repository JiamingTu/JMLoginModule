#
# Be sure to run `pod lib lint JMLoginModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JMLoginModule'
  s.version          = '0.0.3'
  s.summary          = '登录组件（依赖TJMBaseTool）'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
包括登录、验证码登录、忘记密码、注册、修改密码功能(没有sign 功能，后续更新)
                       DESC

  s.homepage         = 'https://github.com/JiamingTu/JMLoginModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JiamingTu' => 'tujiamingdd@sina.com' }
  s.source           = { :git => 'https://github.com/JiamingTu/JMLoginModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'JMLoginModule/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JMLoginModule' => ['JMLoginModule/Assets/*.png']
  # }

  s.public_header_files = 'JMLoginModule/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
