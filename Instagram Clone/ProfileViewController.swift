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
    var pageNumber : Int = 10; //Number of images to be loaded
    
    var uuidArray  = [String]()
    var picturesArray = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        
        //BackGround color
        collectionView?.backgroundColor = .whiteColor()
        
        //Set the title of the navigation bar to the user name
        self.navigationItem.title = PFUser.currentUser()!.username
        
        //Add pull to refresh to the view
        pullTorefresh = UIRefreshControl()
        pullTorefresh.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(pullTorefresh)
        
        //Receive notificaiton
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData:", name: "reloadData", object: nil)
        
        //Load posts
        loadPosts()
        
    }
    
    func reloadData(notification: NSNotification){
      collectionView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout delegate method
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let cellSpacing = CGFloat(1) //Define the space between each cell
        let leftRightMargin = CGFloat(0) //If defined in Interface Builder for "Section Insets"
        let numColumns = CGFloat(3) //The total number of columns you want
        
        let totalCellSpace = cellSpacing * (numColumns - 1)
        let screenWidth = UIScreen.mainScreen().bounds.width
        let width = (screenWidth - leftRightMargin - totalCellSpace) / numColumns
        let height = CGFloat(120) //whatever height you want
        
        return CGSizeMake(width, height);
    }
    
    
    // Configure HeaderView
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
            withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HeaderCollectionReusableView
        
        //Style the profile picture
        styleProfilePucture(headerView.profileImageView)
        
        headerView.userNameLabel.text = (PFUser.currentUser()!.objectForKey("fullName") as? String)
        headerView.bioTextView.text = (PFUser.currentUser()!.objectForKey("bio") as? String)
        headerView.bioTextView.sizeToFit()
        
        let profileImageQuery = PFUser.currentUser()!.objectForKey("profilePicture") as! PFFile
        profileImageQuery.getDataInBackgroundWithBlock { (data : NSData?, error : NSError?) -> Void in
            
            if error == nil{
                headerView.profileImageView.image = UIImage(data: data!)
            } else{
                print(error!.localizedDescription)
            }
        }
        
        //Fetch the number of posts
        let postsQuery = PFQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        
        //set the limit of data to fetch
        postsQuery.countObjectsInBackgroundWithBlock ({ (count : Int32!, error: NSError?) -> Void in
            
            if error == nil{
                headerView.postsLabel.text = "\(count)"
            }else{
                print(error!.localizedDescription)
            }
        }) //End of query execution
        
        //Fetch the number of followers
        let followersQuery = PFQuery(className: "Followers")
        followersQuery.whereKey("following", equalTo: (PFUser.currentUser()?.username)!)
        
        //set the limit of data to fetch
        followersQuery.countObjectsInBackgroundWithBlock ({ (count : Int32!, error: NSError?) -> Void in
            
            if error == nil{
                headerView.followersLabel.text = String(count)
            }else{
                print(error!.localizedDescription)
            }
        }) //End of query execution
        
        //Fetch the number of people following back
        let followingQuery = PFQuery(className: "Followers")
        followingQuery.whereKey("follow", equalTo: (PFUser.currentUser()?.username)!)
        
        //set the limit of data to fetch
        followingQuery.countObjectsInBackgroundWithBlock ({ (count : Int32!, error: NSError?) -> Void in
            
            if error == nil{
                headerView.followingLabel.text = "\(count)"
            }else{
                print(error!.localizedDescription)
            }
        }) //End of query execution
        
        //Implement tap gestures on posts
        let postTapGuesture  = UITapGestureRecognizer(target: self, action: "postTap")
        postTapGuesture.numberOfTapsRequired = 1
        headerView.postsLabel.userInteractionEnabled = true
        headerView.postsLabel.addGestureRecognizer(postTapGuesture)
        
        let followersTapGuesture  = UITapGestureRecognizer(target: self, action: "followersTap")
        followersTapGuesture.numberOfTapsRequired = 1
        headerView.followersLabel.userInteractionEnabled = true
        headerView.followersLabel.addGestureRecognizer(followersTapGuesture)
        
        let followingTapGuesture  = UITapGestureRecognizer(target: self, action: "followingTap")
        followingTapGuesture.numberOfTapsRequired = 1
        headerView.followingLabel.userInteractionEnabled = true
        headerView.followingLabel.addGestureRecognizer(followingTapGuesture)
        
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
    
    //Load user posts.
    func loadPosts(){
        
        //Fetch the data
        let postQuery = PFQuery(className: "Posts")
        postQuery.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        
        //set the limit of data to fetch
        postQuery.limit = pageNumber
        postQuery.addDescendingOrder("createdAt") //Order posts by date created.
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
    
    func postTap (){
        
        if !picturesArray.isEmpty {
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    func followersTap(){
        user = (PFUser.currentUser()?.username)!
        navigationTile = "Followers"
        
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersTableViewController") as! FollowersTableViewController
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func followingTap(){
        user = (PFUser.currentUser()?.username)!
        navigationTile = "Following"
        
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersTableViewController") as! FollowersTableViewController
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func styleProfilePucture(profileImageView: UIImageView){
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 40.0;
        profileImageView.layer.borderWidth = 1;
    }
}
