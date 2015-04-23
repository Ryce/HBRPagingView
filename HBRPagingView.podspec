Pod::Spec.new do |s|

  s.name         = "HBRPagingView"
  s.version      = "0.2.0"
  s.summary      = "simple and elegant paging view with UITableView Style memory preserving reusability functionality"

  s.description  = <<-DESC
                  The UIKit provides a very sophisticaed implementation for Tables and Collections. The one thing that was missing was a horizontally scrollable paging view with the same size of the screen. UICollectionView has powerful memory management features but is not quite right to handle full screen cells. This Framework aims to tackle that problem for views that only show one item per page. The Framework caches and reuses cells in a similar matter as UITableView/UICollectionView
                   DESC

  s.homepage     = "https://github.com/Ryce/HBRPagingView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Ryce" => "hamon@riazy.com" }
  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/Ryce/HBRPagingView.git", :tag => "0.2.0" }

  s.source_files  = "HBRPagingView/*.swift"
  s.requires_arc = true

end
