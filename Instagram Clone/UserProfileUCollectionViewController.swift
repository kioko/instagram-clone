//
//  UserProfileUCollectionViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 17/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse
import UIColor_Hex_Swift

var guestUserName = [String]()

private let reuseIdentifier = "Cell"

class UserProfileUCollectionViewController: UICollectionViewController {
    
    //array to hold data from the server
    var uuidArray  = [String]()
    var picturesArray = [PFFile]()
    
    var pullTorefresh : UIRefreshControl!
    var pageNumber : Int = 12; //Number of images to be loaded
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Enable pull to refresh.
        self.collectionView?.alwaysBounceVertical = true
        
        //BackGround color
        collectionView?.backgroundColor = .whiteColor()
        
        //Set the title of the navigation bar to the user name
        self.navigationItem.title = guestUserName.last
        
        //Back Button
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserProfileUCollectionViewController.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        //Swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(UserProfileUCollectionViewController.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(backSwipe)
        
        //Add pull to refresh to the view
        pullTorefresh = UIRefreshControl()
        pullTorefresh.addTarget(self, action: #selector(UserProfileUCollectionViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(pullTorefresh)
        
        //Load posts
        loadPosts()
        
    }
    
    func back(sender : UIBarButtonItem){
        
        self.navigationController?.popViewControllerAnimated(true)
        
        //Remove the last item from the array
        if !guestUserName.isEmpty{
            guestUserName.removeLast()
        }
        
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
        postQuery.whereKey("username", equalTo: guestUserName.last!)
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //HeaderView Configuration.
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        //Defiine the headerView
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
            withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HeaderCollectionReusableView
        
        //Style the profile picture
        styleProfilePucture(headerView.profileImageView)
        
        //Load guest user data
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: guestUserName.last!)
        
        query.findObjectsInBackgroundWithBlock({ ( objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil{
                if objects!.isEmpty{
                    print("Could not find user")
                }else{
                    for object in objects!{
                        headerView.userNameLabel.text = object.objectForKey("fullName") as? String
                        headerView.bioTextView.text = object.objectForKey("bio") as? String
//                        headerView.bioTextView.sizeToFit()
                        
                        //Fetch the profile picture
                        let profileImageQuery = object.objectForKey("profilePicture") as! PFFile
                        profileImageQuery.getDataInBackgroundWithBlock { (data : NSData?, error : NSError?) -> Void in
                            
                            if error == nil{
                                headerView.profileImageView.image = UIImage(data: data!)
                            } else{
                                print(error!.localizedDescription)
                            }
                        }
                    }
                }
            }else{
                print(error!.localizedDescription)
            }
        })//End of following query block
        
        //Check if the current user is following the guest user
        let followingGuestQuery = PFQuery(className: "Followers")
        followingGuestQuery.whereKey("following", equalTo: PFUser.currentUser()!.username!)
        followingGuestQuery.whereKey("following", equalTo: guestUserName.last!)
        
        followingGuestQuery.countObjectsInBackgroundWithBlock ({ (count : Int32!, error: NSError?) -> Void in
            
            if error == nil{
                if count == 0{ //We are not following the user
                    headerView.buttonFollow.setTitle("Follow", forState: .Normal)
                    headerView.buttonFollow.backgroundColor = .lightGrayColor()
                }else{ //We are following the user
                    headerView.buttonFollow.setTitle("Following", forState: .Normal)
                    headerView.buttonFollow.backgroundColor = UIColor(rgba: "#4dc247")
                }
                headerView.postsLabel.text = "\(count)"
            }else{
                print(error!.localizedDescription)
            }
        }) //End of followingGuestQuery execution
        
        
        //Fetch the number of posts
        let postsQuery = PFQuery(className: "Posts")
        postsQuery.whereKey("username", equalTo: guestUserName.last!)
        
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
        followersQuery.whereKey("following", equalTo: guestUserName.last!)
        
        //set the limit of data to fetch
        followersQuery.countObjectsInBackgroundWithBlock ({ (count : Int32!, error: NSError?) -> Void in
            
            if error == nil{
                headerView.followersLabel.text = String(count)
            }else{
                print(error!.localizedDescription)
            }
        }) //End of followersQuery execution
        
        //Fetch the number of people following back
        let followingQuery = PFQuery(className: "Followers")
        followingQuery.whereKey("follow", equalTo: guestUserName.last!)
        
        //set the limit of data to fetch
        followingQuery.countObjectsInBackgroundWithBlock ({ (count : Int32!, error: NSError?) -> Void in
            
            if error == nil{
                headerView.followingLabel.text = "\(count)"
            }else{
                print(error!.localizedDescription)
            }
        }) //End of query execution
        
        //Implement tap gestures on posts
        let postTapGuesture  = UITapGestureRecognizer(target: self, action: #selector(UserProfileUCollectionViewController.postTap))
        postTapGuesture.numberOfTapsRequired = 1
        headerView.postsLabel.userInteractionEnabled = true
        headerView.postsLabel.addGestureRecognizer(postTapGuesture)
        
        //Implement tap gestures on Followers
        let followersTapGuesture  = UITapGestureRecognizer(target: self, action: #selector(UserProfileUCollectionViewController.followersTap))
        followersTapGuesture.numberOfTapsRequired = 1
        headerView.followersLabel.userInteractionEnabled = true
        headerView.followersLabel.addGestureRecognizer(followersTapGuesture)
        
        //Implement tap gestures on Following
        let followingTapGuesture  = UITapGestureRecognizer(target: self, action: #selector(UserProfileUCollectionViewController.followingTap))
        followingTapGuesture.numberOfTapsRequired = 1
        headerView.followingLabel.userInteractionEnabled = true
        headerView.followingLabel.addGestureRecognizer(followingTapGuesture)
        
        return headerView;
    }
    
    func styleProfilePucture(profileImageView: UIImageView){
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 40.0;
        profileImageView.layer.borderWidth = 1;
    }
    
    func postTap (){
        
        if !picturesArray.isEmpty {
            let index = NSIndexPath(forItem: 0, inSection: 0)
            self.collectionView?.scrollToItemAtIndexPath(index, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    func followersTap(){
        user = guestUserName.last!
        navigationTile = "Followers"
        
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersTableViewController") as! FollowersTableViewController
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    func followingTap(){
        user = guestUserName.last!
        navigationTile = "Following"
        
        let followers = self.storyboard?.instantiateViewControllerWithIdentifier("FollowersTableViewController") as! FollowersTableViewController
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    //Load more images while scrolling down
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height{
            self.loadMorePosts()
        }
    }
    
    //Load more posts
    func loadMorePosts(){
        //Check if there are more objets
        if pageNumber <= picturesArray.count{
            //Increase page size
            pageNumber = pageNumber + 12
            
            //Fetch the data
            let postQuery = PFQuery(className: "Posts")
            postQuery.whereKey("username", equalTo: guestUserName.last!)
            
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
    }
    
}
