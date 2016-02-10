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

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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


}
