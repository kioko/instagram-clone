//
//  ViewController.swift
//  Instagram Clone
//
//  Created by Kioko on 07/02/2016.
//  Copyright © 2016 Thomas Kioko. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchProductViaID()
//        createProduct()
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createProduct(){
        let productsObject = PFObject(className: "Products")
        
        productsObject["name"] = "pizza"
        productsObject["description"] = "Chicken Tikka"
        productsObject["price"] = 900
        
        productsObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            
            if success == true{
                print("Object has been saved with ID: \(productsObject.objectId)")
            }else{
                print(error)
            }
        }
    }
    
    func fetchProductViaID(){
        let query = PFQuery(className: "Products")
        
        query.getObjectInBackgroundWithId("HO8M5N9Z63", block: { (object: PFObject?, error: NSError?) -> Void in
        
            if error != nil{
                print(error)
            }else if let product = object{
               
                product["description"] = "Peri Peri"
                product["price"] = 1400
                
                product.saveInBackground()
            }
        })
    }
    
    
}

