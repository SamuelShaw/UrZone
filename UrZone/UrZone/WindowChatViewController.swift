//
//  WindowChatViewController.swift
//  UrZone
//
//  Created by Samuel Shaw on 1/5/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import UIKit
import Parse

class WindowChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    
    @IBOutlet weak var windowTableView: UITableView!
    
    @IBOutlet weak var windowMessageTextfield: UITextField!
    
    
    var counterNumber = 0
    
    var username : String?
    
    var updateTimer = NSTimer()
    
    let updateDelay = 1.0
    
    var currentData: [[String: String]] = []
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.windowTableView.delegate = self
        self.windowTableView.dataSource = self
        
        self.windowMessageTextfield.delegate = self
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(updateDelay, target: self, selector: "update", userInfo: nil, repeats: true)
        
        print ("\(PFusernameString)")
        
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
    
    func update()
    {
        let query = PFQuery(className: "WindowChat")
        query.limit = 1000
        let objects = try! query.findObjects()
        currentData = []
        for i in objects {
            var finalDictionary: [String: String] = [:]
            finalDictionary["username"] = i.objectForKey("username")! as? String
            finalDictionary["text"] = i.objectForKey("text")! as? String
            currentData.append(finalDictionary)
        }
        currentData = currentData.reverse()
        windowTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("WindowChatCell") as! WindowTableViewCell
        cell.windowChatUser.text = currentData[indexPath.row]["username"]!
        cell.windowChatText.text = currentData[indexPath.row]["text"]!
        
        let radius = cell.windowRoundView.frame.height / 2
        cell.windowRoundView.layer.cornerRadius = radius
        
        return cell
    }
    
    @IBAction func windowSend() {
        let obj = PFObject(className: "WindowChat")
        currentSessionUN = (PFusernameString as? String)!
        obj.setObject(currentSessionUN, forKey: "username")
        
        obj.setObject(windowMessageTextfield.text!, forKey: "text")
        try! obj.save()
        windowMessageTextfield.text = ""
        self.view.endEditing(true)
    }
    
    @IBAction func windowLogoutPressed(sender: AnyObject)
    {
        PFUser.logOut()
        
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("iPhoneStoryboard")
    }
    
    
    
}

