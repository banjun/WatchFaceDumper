platform :macos, '10.15'
use_frameworks!

target 'WatchFaceDumper' do
  pod 'ZIPFoundation'
  pod 'NorthLayout'
  pod '※ikemen'
end

def lift_to_xcode_recommended_settings(pi)
  # to identify whether it is Xcode 15
  xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`

  pi.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.15'
      # suppress recommended settings warnings: automatically select archs
      config.build_settings.delete 'ARCHS'
      
      # for xcode 15+ only
      if config.base_configuration_reference && Integer(xcode_base_version) >= 15
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
  end
  
  pi.pods_project.build_configurations.each do |c|
    # suppress recommended settings warnings: dead code stripping
    c.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
  end
end

post_install do |pi|
  lift_to_xcode_recommended_settings pi
end
