//
//  SignUpViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 08/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    //Button Outlets
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    //ScrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    //Reset defaul srollView size
    var scrollViewHeight : CGFloat = 0
    
    //Keyboard frame size
    var keyboard = CGRect()
    
    //Main Default function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ScrollView Frame size
        scrollView.frame = CGRectMake(0, 0, self.view.frame.width ,self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        //Check notificaiton if keyboard is showing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        
        //Hide keyboard tap guesture
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboardType:")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap) //add the gesture the view
        
        //Make imageView circular
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 4.8
        profileImageView.clipsToBounds = true
        
        //Image tap guesture that invokes UIImagePickerController
        let loadImageTap = UITapGestureRecognizer(target: self, action: "loadProfileImage:")
        loadImageTap.numberOfTapsRequired = 1
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(loadImageTap) //add the gesture the view
        
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
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }
    }
    
    //Hide the keyboard
    func hideKeyboard(notification: NSNotification){
        
        //Define the animation to mive the UI down
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
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
        profileImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
        //dismiss the keyboard
        self.view.endEditing(true)
        
        //Check if any of the textfields are empty
        if (userNameTextField.text!.isEmpty || passwordTextField.text!.isEmpty ||
            confirmPasswordTextField.text!.isEmpty || emailTextField.text!.isEmpty ||
            fullNameTextField.text!.isEmpty || bioTextField.text!.isEmpty ||
            websiteTextField.text!.isEmpty){
                //Show Alert Dialog
                showAlertDialog("Warning", alertMessage: "Please fill all fields")
                
                return
        }
        
        //Check if passwords match
        if (passwordTextField.text != confirmPasswordTextField.text){
              //Show Alert Dialog
            showAlertDialog("Warning", alertMessage: "Passwords don't match")
            
            return
        }
        
        let user = PFUser.currentUser()!
        user.username = userNameTextField.text!.lowercaseString
        user.email = emailTextField.text
        user.password = passwordTextField.text
        
        //Create custom columns in parse
        user["fullName"] = fullNameTextField.text
        user["bio"] = bioTextField.text
        user["website"] = websiteTextField.text!.lowercaseString
        
        user["tel"] = ""
        user["gender"] = ""
        
        //convert the image and send image to server
        let profilePicture = UIImageJPEGRepresentation(profileImageView.image!, 0.5)
        let imageFile = PFFile(name: "profilePicture.jpg", data: profilePicture!)
        user["profilePicture"] = imageFile
        
        user.saveInBackgroundWithBlock{
            (success : Bool, error: NSError?)-> Void in
            
            if success {
                //Save the userName on the device on successfull registation
                NSUserDefaults.standardUserDefaults().setObject(user.username, forKey: "userName")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //Call check login function from App delegate class
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.checkUserLogin()
            }else{
                 self.showAlertDialog("Error", alertMessage: error!.localizedDescription)
            }
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlertDialog(title : String,  alertMessage : String){
        
        //Show an alert dialog
        let alertDialog = UIAlertController(title: title,
            message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Set the Ok Button
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertDialog.addAction(okButton)
        
        //Display the alert dialog
        self.presentViewController(alertDialog, animated: true, completion: nil)
        
    }
    
}
