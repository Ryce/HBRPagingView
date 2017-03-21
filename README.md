[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# HBRPagingView
simple and elegant paging view with UITableView Style memory preserving reusability functionality

# Installation

using cocoapods

`pod 'HBRPagingView', '~> 0.3.0'`

using cartage

`github "Ryce/HBRPagingView" >= 0.3.0`

# Usage

set delegate and datasource, register your class (you can also use the basic HBRPagingViewPage)

```Swift
self.pagingView?.dataSource = self
self.pagingView?.pagingDelegate = self
self.pagingView?.registerClass(CustomPagingViewPage.self, forPageReuseIdentifier: "identifier")
```

datasource should return number of pages and the page, dequeueing is available and should be used

```Swift
// MARK: - PagingView Delegate & DataSource
  
func numberOfPages(pagingView: HBRPagingView) -> UInt {
  return 6
}
  
func pagingView(pagingView: HBRPagingView, viewForPage index: UInt) -> AnyObject {
  let page = pagingView.dequeueReusablePageWithIdentifier("identifier", forIndex: index) as! PagingViewPage
  page.imageView.image = UIImage(named: "\(index)")
  return page
}
```

# Contact



# License
HBRPagingView is available under the MIT license. See the LICENSE file for more info.