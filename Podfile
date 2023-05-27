platform :macos, '10.15'
use_frameworks!

target 'WatchFaceDumper' do
  pod 'ZIPFoundation'
  pod 'NorthLayout'
  pod '※ikemen'
end

def lift_to_xcode_recommended_settings(pi)
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |c|
      c.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.15'
      # suppress recommended settings warnings: automatically select archs
      c.build_settings.delete 'ARCHS'
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
