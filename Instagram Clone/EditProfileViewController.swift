//
//  EditProfileViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 28/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class EditProfileViewController: UIViewController, UIPickerViewDelegate,
UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fullNamteTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var privateTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    //Gender Picker View
    var genderPickerView : UIPickerView!
    let gender = ["Male", "Female"]
    
    //Keyboard frame size
    var keyboard = CGRect()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Declare picker view
        genderPickerView = UIPickerView()
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        genderPickerView.backgroundColor = UIColor.whiteColor()
        genderPickerView.showsSelectionIndicator = true
        genderTextField.inputView = genderPickerView
        
        //Check notificaiton if keyboard is showing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.showKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditProfileViewController.hideKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        fetchUserData()
        
        //Tap Guesture
        //Hide keyboard tap guesture
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.hideKeyboardType(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap) //add the gesture the view
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        scrollView.frame = CGRectMake(0, 0, width, height)
        profilePictureImageView.frame = CGRectMake(width - 70 - 10, 15, 70, 70)
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.width / 2
        profilePictureImageView.clipsToBounds = true
        
        //Make the bio textView have rounded corners
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.borderColor = UIColor(red: 230 / 225.5, green: 230 / 225.5, blue: 230 / 225.5, alpha: 1).CGColor
        bioTextView.layer.cornerRadius = bioTextView.frame.size.width / 50
        bioTextView.clipsToBounds = true
        
        //Image tap guesture that invokes UIImagePickerController
        let loadImageTap = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.loadProfileImage(_:)))
        loadImageTap.numberOfTapsRequired = 1
        profilePictureImageView.userInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(loadImageTap) //add the gesture the view
        
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
            self.scrollView.contentSize.height = self.view.frame.height - self.keyboard.height / 2
        }
    }
    
    //Hide the keyboard
    func hideKeyboard(notification: NSNotification){
        
        //Define the animation to mive the UI down
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.contentSize.height = 0
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
        profilePictureImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchUserData(){
        
        fullNamteTextField.text = (PFUser.currentUser()!.objectForKey("fullName") as? String)
        userNameTextField.text = (PFUser.currentUser()!.objectForKey("username") as? String)
        websiteTextField.text = (PFUser.currentUser()!.objectForKey("website") as? String)
        phoneTextField.text = (PFUser.currentUser()!.objectForKey("tel") as? String)
        bioTextView.text = (PFUser.currentUser()!.objectForKey("bio") as? String)
        emailTextField.text = (PFUser.currentUser()!.objectForKey("email") as? String)
        
        let profileImageQuery = PFUser.currentUser()!.objectForKey("profilePicture") as! PFFile
        profileImageQuery.getDataInBackgroundWithBlock { (data : NSData?, error : NSError?) -> Void in
            
            if error == nil{
                self.profilePictureImageView.image = UIImage(data: data!)
            } else{
                print(error!.localizedDescription)
            }
        }
        
    }
    
    //Validate Email Address
    func validateEmail(email : String) -> Bool{
        
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2}"
        let range = email.rangeOfString(regex, options: .RegularExpressionSearch)
        
        let result = range != nil ? true : false
        
        return result
    }
    
    //Validate Website.
    func validateWebsite(website : String) -> Bool{
        let regex = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = website.rangeOfString(regex, options: .RegularExpressionSearch)
        
        let result = range != nil ? true : false
        
        return result
    }
    
    @IBAction func doneEditProfileAction(sender: AnyObject) {
        
        if !validateEmail(emailTextField.text!){
            showAlertDialog("Error", alertMessage: "Please enter a valid email address")
            return
        }
        
        if !validateWebsite(websiteTextField.text!){
             showAlertDialog("Error", alertMessage: "Please enter a valid web address")
            return
        }
        
        //Send Data to parse.
        let user = PFUser.currentUser()!
        user.username = userNameTextField.text!.lowercaseString
        user.email = emailTextField.text
        
        //Create custom columns in parse
        user["fullName"] = fullNamteTextField.text
        user["bio"] = bioTextView.text
        user["website"] = websiteTextField.text!.lowercaseString
        
        if phoneTextField.text!.isEmpty{
            user["tel"] = ""
        }else{
            user["tel"] = phoneTextField.text
        }
        
        user["gender"] = gender
        
        //convert the image and send image to server
        let profilePicture = UIImageJPEGRepresentation(profilePictureImageView.image!, 0.5)
        let imageFile = PFFile(name: "profilePicture.jpg", data: profilePicture!)
        user["profilePicture"] = imageFile
        
        //Send Data to server.
        user.saveInBackgroundWithBlock{
            (success : Bool, error: NSError?)-> Void in
            
            if success {
              self.view.endEditing(true)
                self.dismissViewControllerAnimated(true, completion: nil)
                
                //Update the home page
                NSNotificationCenter.defaultCenter().postNotificationName("reloadData", object: nil)
            }else{
                self.showAlertDialog("Error", alertMessage: error!.localizedDescription)
            }
        }

    }
    
    //Cancel view
    @IBAction func cancelEditProfileAction(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Picker view methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = gender[row]
        self.view.endEditing(true)
    }
    
    func setTextFieldIcon(uiTextField : UITextField, uiImage : UIImage,
        uimageView: UIImageView){
            
            let iconWidth = 20;
            let iconHeight = 20;
            
            let imageView = UIImageView();
            imageView.image = uiImage;
            
            // set frame on image before adding it to the uitextfield
            imageView.frame = CGRect(x: 5, y: 5, width: iconWidth, height: iconHeight)
            uiTextField.leftViewMode = UITextFieldViewMode.Always
            uiTextField.addSubview(imageView)
            
            //set Padding
            let paddingView = UIView(frame: CGRectMake(0, 0, 25, uiTextField.frame.height))
            uiTextField.leftView = paddingView
            
    }
    
    
    //Displays an Alert message
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
