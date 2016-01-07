//
//  ChatCell.swift
//  UrZone
//
//  Created by Samuel Shaw on 12/16/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit
import Parse

class ChatCell: UITableViewCell
{
    @IBOutlet var chatText: UITextView!
    
    @IBOutlet var chatUser: UILabel!
    
    @IBOutlet weak var roundView: UIView!
    
    @IBOutlet weak var userVotesLabel: UILabel!
    
    @IBOutlet weak var thumbUpIcon: UIImageView!

var parseObject:PFObject?

override func awakeFromNib()
{
    
    let gesture = UITapGestureRecognizer(target: self, action:Selector("onDoubleTap:"))
    gesture.numberOfTapsRequired = 2
    contentView.addGestureRecognizer(gesture)
    
    thumbUpIcon?.hidden = true
    
    super.awakeFromNib()
    }
    
    func onDoubleTap(sender: AnyObject)
    {
        if(parseObject != nil) {
            if var votes:Int? = parseObject!.objectForKey("votes") as? Int {
                votes!++
                
                parseObject!.setObject(votes!, forKey: "votes");
                parseObject!.saveInBackground();
                
                userVotesLabel?.text = "\(votes!) votes";
            }
        }
        
        thumbUpIcon?.hidden = false
        thumbUpIcon?.alpha = 1.0
        
//        thumbUpIcon.animationDuration(anim
//            
//            self.catPawIcon?.alpha = 0
//            
//            }, completion: {
//                (value:Bool) in
//                
//                self.thumbUpIcon?.hidden = true
//        })
//    }
}
}
