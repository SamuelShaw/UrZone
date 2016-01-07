//
//  SignInViewController.swift
//  FinalsPractice
//
//  Created by Samuel Shaw on 12/10/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseTwitterUtils
import ParseFacebookUtilsV4



class SignInViewController: UIViewController, UITextFieldDelegate
{

    @IBOutlet weak var un: UITextField!
    
    @IBOutlet weak var pw: UITextField!
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //set textField delegates
        self.un.delegate = self
        self.pw.delegate = self
        
        // Resign Keyboard
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)

    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        pw.text = ""
    }
    
    override func viewWillAppear(animated: Bool) {
        if (PFUser.currentUser() != nil) {
            print ("\(PFUser.currentUser)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Detect")
                self.presentViewController(viewController, animated: true, completion: nil)
            })
        }
    }

    
    func didTapView()
    {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
  
    // Phil's Login Code
    
    @IBAction func loginButtonTapped(sender: UIButton)
    {
        let username = self.un.text
        let password = self.pw.text
        
        if username?.characters.count < 5
        {
            let alert = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
        }
        else if password?.characters.count < 6
        {
            let alert = UIAlertController(title: "Invalid", message: "Password must be greater than 6 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            
        }
      
        else
        {
            // Run a spinner to show a task in progress
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            //Send a request to login
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                // Stop the spinner
                spinner.stopAnimating()
                
                if ((user) != nil)
                {
                    
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Detect")
                        self.presentViewController(viewController, animated: true, completion: nil) })
                    
                }
                else
                {
                    
                    let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                }
            })
            
        }
    }

    
    @IBAction func facebookButtonTapped(sender: AnyObject)
    {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email"]) { (user:PFUser?, error:NSError?) -> Void in
            
            if (error != nil)
            {
                //Display an alert message
                let myAlert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                myAlert.addAction(okAction)
                
                self.presentViewController(myAlert, animated: true, completion: nil)
                
                return
            }
            
            let requestParameters = ["fields": "id, email, first_name, last_name"]
            
            let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
            userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
                if(error != nil)
                {
                    print("\(error.localizedDescription)")
                    return
                }
                
                if(result != nil)
                {
                    let userId:String = result["id"] as! String
                    let userFirstName:String? = result["first_name"] as? String
                    let userLastName:String? = result["last_name"] as? String
                    let userEmail:String? = result["email"] as? String
                    
                    print("\(userEmail)")
                    print("\(userFirstName)")
                    
                    let myUser:PFUser = PFUser.currentUser()!
                    // Save email address
                    if(userEmail != nil)
                    {
                        myUser.setObject(userEmail!, forKey: "email")
                    }
                    // Save first name
                    if(userFirstName != nil)
                    {
                        myUser.setObject(userFirstName!, forKey: "first_name")
                        //Set username as first name also
                        myUser.setObject(userFirstName!, forKey: "username")
                    }
                    // Save last name
                    if(userLastName != nil)
                    {
                        myUser.setObject(userLastName!, forKey: "last_name")
                    }
                    
                    // Get Facebook profile picture
                    
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    let profilePictureUrl = NSURL(string: userProfile)
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    if(profilePictureData != nil)
                    {
                        let profileFileObject = PFFile(data: profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "profile_picture")
                    }
                    
                    myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if(success)
                        {
                            print("user details are now updated")
                            
                        }
                    })
                }
            }
            
            self.performSegueWithIdentifier("toDetect", sender: self)

            
        }
        
    }
    
    
    
    @IBAction func twitterButtonTapped(sender: AnyObject)
    {
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    self.processTwitterUser()
                    let pfTwitter = PFTwitterUtils.twitter()
                    let twitterUsername = pfTwitter?.screenName
                    PFUser.currentUser()?.setObject(twitterUsername!, forKey: "username")
                    print("User \(twitterUsername)signed up and logged in with Twitter!")
                    self.performSegueWithIdentifier("toChat", sender: self)
                } else {
                    self.processTwitterUser()
                    let pfTwitter = PFTwitterUtils.twitter()
                    let twitterUsername = pfTwitter?.screenName
                    print("User \(twitterUsername)logged in with Twitter!")
                    self.performSegueWithIdentifier("toChat", sender: self)
                }
            } else {
                print("Uh oh. The user cancelled the Twitter login.")
            }
        }
    }
    
    func processTwitterUser()
    {
        let pfTwitter = PFTwitterUtils.twitter()
        
        let twitterUsername = pfTwitter?.screenName
        
        var userDetailsUrl:String = "https://api.twitter.com/1.1/users/show.json?screen_name="
        userDetailsUrl = userDetailsUrl + twitterUsername!
        
        let myUrl = NSURL(string: userDetailsUrl)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "GET"
        
        pfTwitter!.signRequest(request)
        
    }

    
}

