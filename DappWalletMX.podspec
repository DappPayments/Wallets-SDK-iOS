Pod::Spec.new do |s|
  s.name         = "DappWalletMX"
  s.version      = "1.2.0"
  s.summary      = "Dapp is an online payments platform from Mexico"
  s.description  = <<-DESC
Dapp is an online payments platform, focused on the security of its users. This framework is designed for electronic Wallet developers looking to integrate into the Dapp Payments platform.
                   DESC
  s.homepage     = "https://dapp.mx"
  s.license      = "MIT"
  s.author             = { "Dapp Payments" => "devs@dapp.mx" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/DappPayments/Wallets-SDK-iOS.git", :tag => s.version.to_s }
  s.source_files  = "dapp-sdk-wallets-ios", "dapp-sdk-wallets-ios/*.{h,m,swift}"
  s.swift_version = "5.0"
end