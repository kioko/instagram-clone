//
//  FollowersCell.swift
//  Instagram Clone
//
//  Created by Kioko on 15/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class FollowersCell: UITableViewCell {
    
    @IBOutlet weak var followingState: UIButton!
    @IBOutlet weak var followerUserNameLabel: UILabel!
    @IBOutlet weak var followerProfilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.followerProfilePicture.layer.masksToBounds = false
        self.followerProfilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        self.followerProfilePicture.clipsToBounds = true
        self.followerProfilePicture.layer.cornerRadius = 30.0;
        self.followerProfilePicture.layer.borderWidth = 1;
        
        
    }
    
    @IBAction func followUserAction(sender: AnyObject) {
        let followStateTitle = followingState.titleForState(.Normal)
        
        if followStateTitle == "Follow"{
            let object = PFObject(className: "Followers")
            object["follow"] = PFUser.currentUser()?.username
            object["following"] = followerUserNameLabel.text
            object.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                
                if success{
                    //Update the state of the button.
                    self.followingState.setTitle("Following", forState: UIControlState.Normal)
                    self.followingState.backgroundColor = UIColor(rgba: "#4dc247")
                }else{
                    print(error?.localizedDescription)
                }
            })
        }else{
            
            let followersQuery = PFQuery(className: "Followers")
            followersQuery.whereKey("following", equalTo: PFUser.currentUser()!.username!)
            followersQuery.whereKey("following", equalTo: followerUserNameLabel.text!)
            
            followersQuery.findObjectsInBackgroundWithBlock ({ (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error ==  nil{
                    for object in objects!{
                        object.deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            
                            if success{
                                //Update the state of the button.
                                self.followingState.setTitle("Follow", forState: UIControlState.Normal)
                                self.followingState.backgroundColor = UIColor.lightGrayColor()
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
    
}
