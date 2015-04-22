//
// The MIT License (MIT)
//
// Copyright (c) 2015 Hamon Riazy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

@objc protocol HBRPagingViewDelegate : NSObjectProtocol, UIScrollViewDelegate {
  optional func pagingView(pagingView: HBRPagingView, shouldSelectPage page: UInt) -> Bool
  optional func pagingView(pagingView: HBRPagingView, didSelectPage page: UInt)
}

protocol HBRPagingViewDataSource : NSObjectProtocol {
  func pagingView(pagingView: HBRPagingView, viewForPage index: UInt) -> AnyObject
  func numberOfPages(pagingView: HBRPagingView) -> UInt
}

public class HBRPagingView: UIScrollView, UIScrollViewDelegate {
  var cachedPages = Dictionary<UInt, AnyObject>()
  weak var pagingDelegate: HBRPagingViewDelegate?
  weak var dataSource: HBRPagingViewDataSource?
  var registeredClasses = Dictionary<String, AnyClass>()
  
  override public func drawRect(rect: CGRect) {
    super.drawRect(rect)
    self.setupView()
  }
  
  func reloadData() {
    self.setupView()
  }

  func setupView() {
    self.pagingEnabled = true
    self.delegate = self
    if self.dataSource == nil {
      return // BAIL
    }
    let nop = self.dataSource!.numberOfPages(self)
    if nop == 0 {
      return // BAIL
    }
    
    self.contentSize = CGSizeMake(self.bounds.size.width * CGFloat(nop), self.bounds.size.height)
    let pageIndex = self.currentPage()
    
    if self.dataSource?.numberOfPages(self) >= pageIndex {
      if let page: AnyObject = self.dataSource?.pagingView(self, viewForPage: pageIndex) {
        self.addPage(page, forIndex: pageIndex)
      }
      if pageIndex > 0 {
        if let page: AnyObject = self.dataSource?.pagingView(self, viewForPage: pageIndex - 1) {
          self.addPage(page, forIndex: pageIndex - 1)
        }
      }
      if self.dataSource?.numberOfPages(self) > pageIndex {
        if let page: AnyObject = self.dataSource?.pagingView(self, viewForPage: pageIndex + 1) {
          self.addPage(page, forIndex: pageIndex + 1)
        }
      }
    }
  }
  
  func addPage(page: AnyObject, forIndex pageIndex: UInt) {
    if let cachedPage: AnyObject = self.cachedPages[pageIndex] {
      if !cachedPage.isEqual(page) {
        self.cachedPages[pageIndex] = page
        if page.superview != self {
          self.addSubview(page as! UIView)
        }
      }
    } else {
      self.cachedPages[pageIndex] = page
      if page.superview != self {
        self.addSubview(page as! UIView)
      }
    }
    (page as! UIView).frame = CGRectMake(CGFloat(pageIndex) * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)
  }
  
  func registerClass(pageClass: AnyClass, forPageReuseIdentifier identifier: String) {
      self.registeredClasses[identifier] = pageClass
  }
  
  func dequeueReusablePageWithIdentifier(identifier: String, forIndex index: UInt) -> AnyObject {
    if self.registeredClasses[identifier] == nil {
      NSException(name: "PageNotRegisteredException", reason: "The identifier did not match any of the registered classes", userInfo: nil).raise()
      return HBRPagingViewPage()
    }
    if let page: AnyObject = self.cachedPages[index] {
      return page
    } else {
      for key: UInt in self.cachedPages.keys.array {
        let distance = fabs(Double(key) - Double(self.currentPage()))
        if distance > 1 && self.cachedPages[key]!.isKindOfClass(self.registeredClasses[identifier]!) {
          // still have to check if that same object has been used somewhere else
          let page: AnyObject = self.cachedPages[key]!
          self.cachedPages.removeValueForKey(key)
          return page
        }
      }
      let newInstance = self.registeredClasses[identifier]!.new() as! HBRPagingViewPage
      newInstance.frame = self.bounds
      newInstance.contentView.frame = newInstance.bounds
      return newInstance
    }
  }
  
  public func scrollViewDidScroll(scrollView: UIScrollView) {
    if let numberOfPages = self.dataSource?.numberOfPages(self) {
      let offsetAmount = Int(fmin(fmax(0, self.contentOffset.x / self.bounds.size.width), CGFloat(numberOfPages)))
      let direction = ((offsetAmount - Int(self.currentPage())) == 0 ? 1 : -1)
      let index = Int(self.currentPage()) + direction
      if let page: AnyObject = self.dataSource?.pagingView(self, viewForPage: UInt(index)) {
        self.addPage(page, forIndex: UInt(index))
      }
    }
  }
  
  func currentPage() -> UInt {
    return UInt(round(self.contentOffset.x/self.bounds.size.width))
  }
  
}

import UIKit

class HBRPagingViewPage: UIView {
  
  let contentView = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.frame = self.bounds
    self.addSubview(self.contentView)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.contentView.frame = self.bounds
    self.addSubview(self.contentView)
  }
  
}

