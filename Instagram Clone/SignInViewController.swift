//
//  SignInViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 08/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController {
    
    @IBOutlet weak var instagramLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Keyboard frame size
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the label font style
        instagramLabel.font = UIFont(name: "Pacifico", size: 50)
        
        
        //Check notificaiton if keyboard is showing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
        
        //Hide keyboard tap guesture
        let hideTap = UITapGestureRecognizer(target: self, action: "hideKeyboardType:")
        hideTap.numberOfTapsRequired = 1
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap) //add the gesture the view
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func signInAction(sender: AnyObject) {
        
        //Hide the keyboard
        self.view.endEditing(true)
        
        if (userNameTextField.text!.isEmpty || passwordTextField.text!.isEmpty){
            showAlertDialog("Warning", alertMessage: "Please fill all fields")
        }
        
        //Verify user credentials
        PFUser.logInWithUsernameInBackground(userNameTextField.text!, password: passwordTextField.text!) {(user: PFUser?, error: NSError?) -> Void in
            
            if error == nil{
                //Save the user
                NSUserDefaults.standardUserDefaults().setObject(user?.username, forKey: "userName")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //Call check login function from App delegate class
                let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.checkUserLogin()
            }else{
                self.showAlertDialog("Error", alertMessage: error!.localizedDescription)
            }
        }
    }
    
    @IBAction func signUpAction(sender: AnyObject) {
    }
    
    @IBAction func forgotPasswordAction(sender: AnyObject) {
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
//            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }
    }
    
    //Hide the keyboard
    func hideKeyboard(notification: NSNotification){
        
        //Define the animation to mive the UI down
        UIView.animateWithDuration(0.4) { () -> Void in
//            self.scrollView.frame.size.height = self.view.frame.height
        }
    }

    
    
}
