//
//  PasswordRecoverViewController.swift
//  UrZone
//
//  Created by Samuel Shaw on 1/3/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import UIKit
import Parse

class PasswordRecoverViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var userEmailTextfield: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.userEmailTextfield.delegate = self

        // Resign Keyboard
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func didTapView()
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func recoverPasswordPressed(sender: AnyObject)
    {
        let userEmail = userEmailTextfield.text!
        PFUser.requestPasswordResetForEmailInBackground(userEmail) {
            (success: Bool, error: NSError?) -> Void in
            if (success)
            {
                let successMessage = "Great! We've sent you an email on resetting your password to \(userEmail). Check your email now!"
                self.displayMessage(successMessage)
                return
            }
            
            if (error != nil)
            {
                let errorMessage:String = error?.userInfo["error"] as! String
                self.displayMessage(errorMessage)
            }
        }
    }
    
    func displayMessage(theMessage:String)
    {
        // Display alert message with confirmation
        let myAlert = UIAlertController(title: "Alert", message: theMessage, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default) {
            action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
