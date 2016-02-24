//
//  HeaderCollectionReusableView.swift
//  Instagram Clone
//
//  Created by Kioko on 12/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class HeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var followingTitleLabel: UILabel!
    @IBOutlet weak var followersTitleLabel: UILabel!
    @IBOutlet weak var buttonFollow: UIButton!
    
    @IBAction func buttonFollowAction(sender: AnyObject) {
        let followStateTitle = buttonFollow.titleForState(.Normal)
        
        if followStateTitle == "Follow"{
            let object = PFObject(className: "Followers")
            object["follow"] = PFUser.currentUser()?.username
            object["following"] = guestUserName.last!
            
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                
                if success{
                    //Update the state of the button.
                    self.buttonFollow.setTitle("Following", forState: UIControlState.Normal)
                    self.buttonFollow.backgroundColor = UIColor(rgba: "#4dc247")
                }else{
                    print(error?.localizedDescription)
                }
            })
        }else{
            
            let followersQuery = PFQuery(className: "Followers")
            followersQuery.whereKey("following", equalTo: PFUser.currentUser()!.username!)
            followersQuery.whereKey("following", equalTo: guestUserName.last!)
            
            followersQuery.findObjectsInBackgroundWithBlock ({ (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error ==  nil{
                    for object in objects!{
                        object.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            
                            if success{
                                //Update the state of the button.
                                self.buttonFollow.setTitle("Follow", forState: UIControlState.Normal)
                                self.buttonFollow.backgroundColor = UIColor.lightGrayColor()
                            }else{
                                print(error?.localizedDescription)
                            }
                        })
                    }
                }else{
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    @IBAction func editProfileAction(sender: AnyObject) {
    }
}
