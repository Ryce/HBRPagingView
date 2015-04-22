//
//  HBRPagingViewPage.swift
//  Belle
//
//  Created by Hamon Riazy on 11/04/15.
//  Copyright (c) 2015 getbelle. All rights reserved.
//

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
