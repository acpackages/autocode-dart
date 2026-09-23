Pod::Spec.new do |s|
  s.name             = 'ac_printing'
  s.version          = '1.0.0'
  s.summary          = 'Native cross-platform printing plugin for ac_printing'
  s.description      = <<-DESC
Native iOS printing implementation for ac_printing.
                       DESC
  s.homepage         = 'https://github.com/autocode/ac_printing'
  s.license          = { :type => 'BSD' }
  s.author           = { 'AutoCode' => 'email@autocode.run' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.0'
end
