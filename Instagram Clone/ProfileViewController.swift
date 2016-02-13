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

    override func viewDidLoad() {
        super.viewDidLoad()

        //BackGround color
        collectionView?.backgroundColor = .whiteColor()
        
        //Set the title of the navigation bar to the user name
        self.navigationItem.title = PFUser.currentUser()!.username
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
            withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! HeaderCollectionReusableView
        
        
        headerView.userNameLabel.text = (PFUser.currentUser()!.objectForKey("fullName") as? String)
        headerView.bioTextView.text = (PFUser.currentUser()!.objectForKey("bio") as? String)
        
        let profileImageQuery = PFUser.currentUser()!.objectForKey("profilePicture") as! PFFile
        profileImageQuery.getDataInBackgroundWithBlock { (data : NSData?, error : NSError?) -> Void in
            
            if error == nil{
                headerView.profileImageView.image = UIImage(data: data!)
            }
        }
        
        return headerView;
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    /*
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }
*/

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
