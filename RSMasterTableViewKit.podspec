Pod::Spec.new do |s|

  s.name         = "RSMasterTableViewKit"
  s.version      = "1.1"
  s.summary      = "A comprehensive UITableView which handles everything that you need."

  s.description  = <<-DESC
    All-In-One UITableView Kit with inbuilt PullToRefresh, Pagination, EmptyDataSet, Indicator, Networking and much more..
                    DESC

  s.homepage     = "https://github.com/rushisangani/RSMasterTableViewKit"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Rushi Sangani" => "rushisangani@gmail.com" }
  s.social_media_url   = "https://github.com/rushisangani"


  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/rushisangani/RSMasterTableViewKit.git", :tag => s.version }


  s.source_files  = "RSMasterTableViewKit", "RSMasterTableViewKit/**/*.{swift}"
  s.resources     = "RSMasterTableViewKit/**/*.{xib}"

  s.requires_arc = true
  s.swift_version = "4.0"
  s.pod_target_xcconfig = { "SWIFT_VERSION" => "4" }

end

