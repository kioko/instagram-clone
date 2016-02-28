//
//  EditProfileViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 28/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    }
    
    
    @IBAction func doneEditProfileAction(sender: AnyObject) {
    }
    
    //Cancel view 
    @IBAction func cancelEditProfileAction(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
