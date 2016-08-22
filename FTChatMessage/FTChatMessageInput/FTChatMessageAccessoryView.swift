//
//  FTChatMessageAccessoryView.swift
//  ChatMessageDemoProject
//
//  Created by liufengting on 16/4/21.
//  Copyright © 2016年 liufengting https://github.com/liufengting . All rights reserved.
//

import UIKit

@objc protocol FTChatMessageAccessoryViewDataSource : NSObjectProtocol {

    func ftChatMessageAccessoryViewItemCount() -> NSInteger
    func ftChatMessageAccessoryViewImageForItemAtIndex(index : NSInteger) -> UIImage
    func ftChatMessageAccessoryViewTitleForItemAtIndex(index : NSInteger) -> String
 
}
@objc protocol FTChatMessageAccessoryViewDelegate : NSObjectProtocol {
    
    func ftChatMessageAccessoryViewDidTappedOnItemAtIndex(index : NSInteger)
    
}

class FTChatMessageAccessoryView: UIView, UIScrollViewDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var accessoryDataSource : FTChatMessageAccessoryViewDataSource!
    var accessoryDelegate : FTChatMessageAccessoryViewDelegate!

    func setupWithDataSource(accessoryViewDataSource : FTChatMessageAccessoryViewDataSource , accessoryViewDelegate : FTChatMessageAccessoryViewDelegate) {
        
        self.setNeedsLayout()
        
        accessoryDataSource = accessoryViewDataSource
        accessoryDelegate = accessoryViewDelegate

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(0.1) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.setupAccessoryView()
        }
    }
    

    
    func setupAccessoryView() {
        
        if accessoryDelegate == nil || accessoryDataSource == nil {
            NSException(name: "Notice", reason: "FTChatMessageAccessoryView. Missing accessoryDelegate or accessoryDelegate", userInfo: nil).raise()
            return
        }

        let totalCount = accessoryDataSource.ftChatMessageAccessoryViewItemCount()
        let totalPage = NSInteger(ceilf(Float(totalCount) / 8))
        self.pageControl.numberOfPages = totalPage
        self.scrollView.contentSize = CGSizeMake(self.bounds.width * CGFloat(totalPage), self.bounds.height)

        
        let horizontalMargin : CGFloat = 25
        let verticalMargin : CGFloat = 25
        let width : CGFloat = 60
        let height : CGFloat = width + 20
        let xMargin : CGFloat = (self.bounds.width - horizontalMargin*2 - width*4)/3
        let yMargin : CGFloat = (self.bounds.height - verticalMargin*2 - height*2)
        
 
        for i in 0...totalCount-1 {
            
            let currentPage = i / 8
            let indexForCurrentPage = i % 8
            
            let x = self.bounds.width * CGFloat(currentPage) + horizontalMargin + (xMargin + width)*CGFloat(i % 4)
            let y = verticalMargin + (yMargin + height) * CGFloat(indexForCurrentPage / 4)

            let item : FTChatMessageAccessoryItem = NSBundle.mainBundle().loadNibNamed("FTChatMessageAccessoryItem", owner: nil, options: nil)[0] as! FTChatMessageAccessoryItem
            item.frame  =  CGRectMake(x, y, width, height)
            
            let image = accessoryDataSource.ftChatMessageAccessoryViewImageForItemAtIndex(i)
            let string = accessoryDataSource.ftChatMessageAccessoryViewTitleForItemAtIndex(i)
            
            
            item.setupWithImage(image, name: string, index: i)
            item.addTarget(self, action: #selector(self.buttonItemTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.scrollView.addSubview(item)
           
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentPage = lroundf(Float(scrollView.contentOffset.x/self.bounds.width))
        self.pageControl.currentPage = currentPage
    }

    
    func buttonItemTapped(sender : UIButton) {
        
        if (accessoryDelegate != nil) {
            accessoryDelegate.ftChatMessageAccessoryViewDidTappedOnItemAtIndex(sender.tag)
        }
        
    }


}
