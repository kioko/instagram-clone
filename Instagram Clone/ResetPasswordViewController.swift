//
//  ResetPasswordViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 10/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func resetPasswordAction(sender: AnyObject) {
        
        //Hide the keyboard
        self.view.endEditing(true)
        
        if emailAddressTextField.text!.isEmpty{
            //Show Alert Dialog
            showAlertDialog("Warning", alertMessage: "Please enter your email address.")
        }
    
        PFUser.requestPasswordResetForEmailInBackground(emailAddressTextField.text!){
            (success: Bool, error: NSError?) -> Void in
            
            if success{
                self.showResetAlertDialog("Success", alertMessage: "Reset instruction has been sent to your email address.")
            }
        }
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
    
    func showResetAlertDialog(title : String,  alertMessage : String){
        
        //Show an alert dialog
        let alertDialog = UIAlertController(title: title,
            message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        //Set the Ok Button
        let okButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertDialog.addAction(okButton)
        
        //Display the alert dialog
        self.presentViewController(alertDialog, animated: true, completion: nil)
    }
}
