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

@objc public protocol HBRPagingViewDelegate : NSObjectProtocol, UIScrollViewDelegate {
    @objc optional func pagingView(_ pagingView: HBRPagingView, shouldSelectPage page: UInt) -> Bool
    @objc optional func pagingView(_ pagingView: HBRPagingView, didSelectPage page: UInt)
}

public protocol HBRPagingViewDataSource : NSObjectProtocol {
    func pagingView(_ pagingView: HBRPagingView, viewForPage index: UInt) -> AnyObject
    func numberOfPages(_ pagingView: HBRPagingView) -> UInt
}

public class HBRPagingView: UIScrollView, UIScrollViewDelegate {
    
    public weak var pagingDelegate: HBRPagingViewDelegate?
    public weak var dataSource: HBRPagingViewDataSource?
    
    private var cachedPages = [UInt: AnyObject]()
    private var registeredClasses = [String: AnyClass]()
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        self.setupView()
    }
    
    open func reloadData() {
        self.setupView()
    }
    
    private func setupView() {
        self.isPagingEnabled = true
        self.delegate = self
        if self.dataSource == nil {
            return // BAIL
        }
        let nop = self.dataSource!.numberOfPages(self)
        if nop == 0 {
            return // BAIL
        }
        
        self.contentSize = CGSize(width: self.bounds.size.width * CGFloat(nop), height: self.bounds.size.height)
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
    
    private func addPage(_ page: AnyObject, forIndex pageIndex: UInt) {
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
        (page as! UIView).frame = CGRect(x: CGFloat(pageIndex) * self.bounds.size.width, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
    }
    
    open func register(_ pageClass: AnyClass, forPageReuseIdentifier identifier: String) {
        self.registeredClasses[identifier] = pageClass
    }
    
    open func dequeueReusablePage(with identifier: String, forIndex index: UInt) -> AnyObject {
        if self.registeredClasses[identifier] == nil {
            NSException(name: NSExceptionName(rawValue: "PageNotRegisteredException"), reason: "The identifier did not match any of the registered classes", userInfo: nil).raise()
            return HBRPagingViewPage()
        }
        if let page: AnyObject = self.cachedPages[index] {
            return page
        } else {
            for key: UInt in self.cachedPages.keys {
                let distance = fabs(Double(key) - Double(self.currentPage()))
                if distance > 1 && self.cachedPages[key]!.isKind(of: self.registeredClasses[identifier]!) {
                    // still have to check if that same object has been used somewhere else
                    let page: AnyObject = self.cachedPages[key]!
                    self.cachedPages.removeValue(forKey: key)
                    return page
                }
            }
            
            HBRPagingViewPage.self
            
            let objType = registeredClasses[identifier] as! HBRPagingViewPage.Type
            let newInstance = objType.init()
            newInstance.frame = self.bounds
            newInstance.contentView.frame = newInstance.bounds
            return newInstance
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let numberOfPages = self.dataSource?.numberOfPages(self) {
            let offsetAmount = Int(fmin(fmax(0, self.contentOffset.x / self.bounds.size.width), CGFloat(numberOfPages)))
            let direction = ((offsetAmount - Int(self.currentPage())) == 0 ? 1 : -1)
            let index = Int(self.currentPage()) + direction
            if index >= Int(numberOfPages) {
                return
            }
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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


open class HBRPagingViewPage: UIView {
    
    open let contentView = UIView()
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.contentView.frame = self.bounds
        self.addSubview(self.contentView)
    }
    
}

