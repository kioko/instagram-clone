//
//  FollowersTableViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 15/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse
import UIColor_Hex_Swift


var navigationTile = String()
var user = String()

class FollowersTableViewController: UITableViewController {
    
    var userNameArray = [String]()
    var picturesArray = [PFFile]()
    // A 'temp' array to store user object data. eg, userName, profile picture
    var followersArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = navigationTile
        
        if navigationTile == "Followers"{
            loadFollowers()
        }
        
        if navigationTile == "Following"{
            loadFollowing()
        }
        
    }
    
    //Load users following you.
    func loadFollowers(){
        
        //Fetch the number of followers
        let followersQuery = PFQuery(className: "Followers")
        followersQuery.whereKey("following", equalTo: user)
        
        followersQuery.findObjectsInBackgroundWithBlock ({ (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil{
                //clean up the array
                self.followersArray.removeAll(keepCapacity: false)
                
                for object in objects!{
                    self.followersArray.append(object.valueForKey("follow") as! String)
                    
                }
                
                //Find people current user is following data in parse "User" class
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followersArray)
                query?.addDescendingOrder("createdAt")
                
                query?.findObjectsInBackgroundWithBlock({ ( objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil{
                        self.userNameArray.removeAll(keepCapacity: false)
                        self.picturesArray.removeAll(keepCapacity: false)
                        
                        for object in objects!{
                            self.userNameArray.append(object.valueForKey("username") as! String)
                            self.picturesArray.append(object.valueForKey("profilePicture") as! PFFile)
                            self.tableView.reloadData()
                            
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })//End of following query block
            }else{
                print(error!.localizedDescription)
            }
        })//End of followers query block
        
        
    }
    
    //Load people you are following
    func loadFollowing(){
        //Fetch the number of people following back
        let followingQuery = PFQuery(className: "Followers")
        followingQuery.whereKey("follow", equalTo: user)
        
        followingQuery.findObjectsInBackgroundWithBlock ({ (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil{
                //clean up the array
                self.followersArray.removeAll(keepCapacity: false)
                
                for object in objects!{
                    self.followersArray.append(object.valueForKey("following") as! String)
                }
                
                //Find the users following a user
                let query = PFQuery(className: "_User")
                query.whereKey("username", containedIn: self.followersArray)
                query.addDescendingOrder("createdAt")
                
                //Find users followed by user
                query.findObjectsInBackgroundWithBlock({ ( objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil{
                        self.followersArray.removeAll(keepCapacity: false)
                        
                        // Find related objects in parse "User" class
                        for object in objects!{
                            self.userNameArray.append(object.valueForKey("username") as! String)
                            self.picturesArray.append(object.valueForKey("profilePicture") as! PFFile)
                            self.tableView.reloadData()
                        }
                    }else{
                        print(error!.localizedDescription)
                    }
                })//End of following query block
            }else{
                print(error!.localizedDescription)
            }
        })//End of followers query block
    }
    
    //Number of cells
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNameArray.count
    }
    
    
    // Configure the cell...
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowersCell") as! FollowersCell
        
        cell.followerUserNameLabel.text = userNameArray[indexPath.row]
        picturesArray[indexPath.row].getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
            if error == nil{
                cell.followerProfilePicture.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        
        let query = PFQuery(className: "Followers")
        query.whereKey("follow", equalTo: PFUser.currentUser()!.username!)
        query.whereKey("following", equalTo: cell.followerUserNameLabel.text!)
        
        //set the limit of data to fetch
        query.countObjectsInBackgroundWithBlock ({ (count : Int32!, error: NSError?) -> Void in
            
            if count == 0{
                cell.followingState.setTitle("Follow", forState: UIControlState.Normal)
                cell.followingState.backgroundColor = .lightGrayColor()
            }else{
                cell.followingState.setTitle("Following", forState: UIControlState.Normal)
                cell.followingState.backgroundColor = UIColor(rgba: "#4dc247")
                
            }
        }) //End of query execution
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FollowersCell
        
        //If user tapped on himself navigate to home
        if cell.followerUserNameLabel.text! == PFUser.currentUser()!.username {
            let homeStoryBoard = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
            self.navigationController?.pushViewController(homeStoryBoard, animated: true)
        }else{
            
            //Set the userName
            guestUserName.append(cell.followerUserNameLabel.text!)
            
            let userStoryBoard = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfileUCollectionViewController") as! UserProfileUCollectionViewController
            self.navigationController?.pushViewController(userStoryBoard, animated: true)
        }
        
    }
    
    
}
