#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ac_quickjs.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ac_quickjs'
  s.version          = '3.3.0'
  s.summary          = 'A high-performance JavaScript runtime for Flutter applications, built with Rust and powered by QuickJS.'
  s.description      = <<-DESC
A high-performance JavaScript runtime for Flutter applications, built with Rust and powered by QuickJS.
                       DESC
  s.homepage         = 'https://github.com/ShreeHari-Softech/ac_quickjs'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'AutoCode' => 'support@autocode.dev' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build Rust library',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust ac_quickjs',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ["${BUILT_PRODUCTS_DIR}/libac_quickjs.a"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libac_quickjs.a',
  }
end
