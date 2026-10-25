# Adds the home-screen widget extension (ios/ZeroWidget) to Runner.xcodeproj. Run by the iOS build on GitHub
# Actions before `flutter build ios`: there is no Xcode on the developer's machine to add the target by hand.
# Uses the xcodeproj gem that ships with CocoaPods.
require 'xcodeproj'

project_path = File.expand_path('../Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)
abort 'ZeroWidget target is already in the project' if project.targets.any? { |t| t.name == 'ZeroWidget' }

app = project.targets.find { |t| t.name == 'Runner' }
widget = project.new_target(:app_extension, 'ZeroWidget', :ios, '15.0', nil, :swift)

group = project.main_group.new_group('ZeroWidget', 'ZeroWidget')
widget_swift = group.new_reference('ZeroWidget.swift')
store_swift = group.new_reference('WidgetStore.swift')
group.new_reference('Info.plist')
group.new_reference('ZeroWidget.entitlements')
xcconfig = group.new_reference('ZeroWidget.xcconfig')
widget.add_file_references([widget_swift, store_swift])
# The app writes the widget's data into the same App Group.
app.add_file_references([store_swift])

widget.build_configurations.each do |config|
  config.base_configuration_reference = xcconfig
  s = config.build_settings
  s['PRODUCT_NAME'] = 'ZeroWidget'
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.tonyvinsenty.smokingApp.ZeroWidget'
  s['INFOPLIST_FILE'] = 'ZeroWidget/Info.plist'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['CODE_SIGN_ENTITLEMENTS'] = 'ZeroWidget/ZeroWidget.entitlements'
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['SKIP_INSTALL'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

app.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

app.add_dependency(widget)
embed = app.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
embed.add_file_reference(widget.product_reference, true).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
# Right after Resources, before Flutter's "Thin Binary" script: otherwise Xcode reports a dependency cycle.
app.build_phases.delete(embed)
resources = app.build_phases.index { |p| p.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase) }
app.build_phases.insert(resources + 1, embed)

project.save
puts "ZeroWidget target added; Runner phases: #{app.build_phases.map(&:display_name).join(' → ')}"
