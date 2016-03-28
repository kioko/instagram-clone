//
//  UploadViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 20/03/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse
import UIColor_Hex_Swift

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    //Keyboard frame size
    var keyboard = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.enabled = false
        shareButton.backgroundColor = .lightGrayColor()
        
        //Image tap guesture that invokes UIImagePickerController
        let loadImageTap = UITapGestureRecognizer(target: self, action: #selector(UploadViewController.loadProfileImage(_:)))
        loadImageTap.numberOfTapsRequired = 1
        pictureImageView.userInteractionEnabled = true
        pictureImageView.addGestureRecognizer(loadImageTap) //add the gesture the view
        
    }
    
    //Hide the keyboard if the user taps outside the keyboard
    func hideKeyboardType(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    //Show keyboard and align it with the view
    func showKeyboard(notification: NSNotification){
        
        //Define Keyboard size
        keyboard = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey]!.CGRectValue)!
        
        //Define the animation to mive the UI up
        UIView.animateWithDuration(0.4) { () -> Void in
            
        }
    }
    
    //Hide the keyboard
    func hideKeyboard(notification: NSNotification){
        
        //Define the animation to mive the UI down
        UIView.animateWithDuration(0.4) { () -> Void in
            
        }
    }
    
    //Allow the user to select image from gallary
    func loadProfileImage(recognizer: UITapGestureRecognizer){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary //Location to select imaged
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Update the profile picture image with the selected image from the gallery
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        //Update the imageView with the selected image from the gallery
        pictureImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        //Enable share button
        shareButton.enabled = true
        shareButton.backgroundColor = UIColor(rgba: "#4dc247")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareImageAction(sender: AnyObject) {
        
        //Dismiss the keyboard
        self.view.endEditing(true)
        
        //Send Data to server
        let object = PFObject(className: "Posts")
        object["username"] = PFUser.currentUser()!.username
        object["profilePicture"] = PFUser.currentUser()!.valueForKey("profilePicture") as! PFFile
        object["uuid"] = "\(PFUser.currentUser()!.username) \(NSUUID().UUIDString)"
        
        if captionTextView.text.isEmpty{
            object["comment"] = ""
        }else{
            object["comment"] = captionTextView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
        }
        
        //convert the image and send image to server
        let profilePicture = UIImageJPEGRepresentation(pictureImageView.image!, 0.5)
        let imageFile = PFFile(name: "picture.jpg", data: profilePicture!)
        object["Pictures"] = imageFile
        
        object.saveInBackgroundWithBlock({
            (success : Bool, error: NSError?)-> Void in
            
            if error == nil {
                
                //Clear the data
                self.viewDidLoad()
                
                NSNotificationCenter.defaultCenter().postNotificationName("postUploaded", object: nil)
                //select the first item on the tabBar
                self.tabBarController!.selectedIndex = 0
            }else{
                print(error!.localizedDescription)
            }
        })
    }
    
}
