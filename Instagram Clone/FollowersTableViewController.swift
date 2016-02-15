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
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
