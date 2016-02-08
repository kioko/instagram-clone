//
//  SignUpViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 08/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    //Button Outlets
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    //ScrollView
    @IBOutlet weak var srollView: UIScrollView!
    
    //Reset defaul srollView size
    var scrollViewHeight : CGFloat = 0
    
    //Keyboard frame size
    var keyboard = CGRect()
    
    //Main Default function
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func signUpAction(sender: AnyObject) {
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
