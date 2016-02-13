//
//  ProfileViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 12/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UICollectionViewController {
    
    var pullTorefresh : UIRefreshControl!
    var pageNumber : Int = 10;
    
    var uuidArray  = [String]()
    var picturesArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //BackGround color
        collectionView?.backgroundColor = .whiteColor()
        
        //Set the title of the navigation bar to the user name
        self.navigationItem.title = PFUser.currentUser()!.username
        
        //Add pull to refresh to the view
        pullTorefresh = UIRefreshControl()
        pullTorefresh.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(pullTorefresh)
        
        //Load posts
        loadPosts()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Configure HaderView
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
            withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HeaderCollectionReusableView
        
        
        headerView.userNameLabel.text = (PFUser.currentUser()!.objectForKey("fullName") as? String)
        headerView.bioTextView.text = (PFUser.currentUser()!.objectForKey("bio") as? String)
        
        let profileImageQuery = PFUser.currentUser()!.objectForKey("profilePicture") as! PFFile
        profileImageQuery.getDataInBackgroundWithBlock { (data : NSData?, error : NSError?) -> Void in
            
            if error == nil{
                headerView.profileImageView.image = UIImage(data: data!)
            } else{
                print(error!.localizedDescription)
            }
        }
        
        return headerView;
    }
    
    // Number of cells
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picturesArray.count
    }
    
    //Cell configuration
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //Declare and initialise the cell.
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        //Load the image for the array to the cell.
        picturesArray[indexPath.row].getDataInBackgroundWithBlock { (data : NSData?, error : NSError?) -> Void in
            if error == nil{
                cell.photoImageView.image = UIImage(data: data!)
            }else{
                print(error!.localizedDescription)
            }
        }
        return cell
    }
    
    
    //This function is called when the user pulls down the view and data is reloaded.
    func refresh(){
        //Reload the data
        collectionView?.reloadData()
        
        //Stop the refesh action
        pullTorefresh.endRefreshing()
    }
    
    func loadPosts(){
        
        //Fetch the data
        let postQuery = PFQuery(className: "Posts")
        postQuery.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        
        //set the limit of data to fetch
        postQuery.limit = pageNumber
        postQuery.findObjectsInBackgroundWithBlock ({ (objects : [PFObject]?, error: NSError?) -> Void in
            
            if error == nil{
                
                //Clear data
                self.uuidArray.removeAll(keepCapacity: false)
                self.picturesArray.removeAll(keepCapacity: false)
                
                //Loop through the data
                for object in objects!{
                    //Add data from uuid to the uuidArray
                    self.uuidArray.append(object.valueForKey("uuid") as! String)
                    self.picturesArray.append(object.valueForKey("Pictures") as! PFFile)
                }
                
                //Reload the collectionView
                self.collectionView?.reloadData()
            }else{
                print(error!.localizedDescription)
            }
        }) //End of query execution
    }
}
