//
//  ChatViewController.swift
//  UrZone
//
//  Created by Samuel Shaw on 12/16/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit
import Parse

let PFusernameString = PFUser.currentUser()!.objectForKey("username")

var currentSessionUN =  ""
var currentSessionPW = ""

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageTextfield: UITextField!
    

    var counterNumber = 0
    
    var username : String?
    
    var updateTimer = NSTimer()
    
    let updateDelay = 1.0
    
    var currentData: [[String: String]] = []
    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.messageTextfield.delegate = self
        
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
    
    func update() {
        let query = PFQuery(className: "Chat")
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
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomChatCell") as! ChatCell
        cell.chatUser.text = currentData[indexPath.row]["username"]!
        cell.chatText.text = currentData[indexPath.row]["text"]!
        
        let radius = cell.roundView.frame.height / 2
        cell.roundView.layer.cornerRadius = radius
        
        return cell
    }
    
    @IBAction func send() {
        let obj = PFObject(className: "Chat")
        currentSessionUN = (PFusernameString as? String)!
        obj.setObject(currentSessionUN, forKey: "username")
        
        obj.setObject(messageTextfield.text!, forKey: "text")
        try! obj.save()
        messageTextfield.text = ""
        self.view.endEditing(true)
    }
    
    @IBAction func logoutPressed(sender: AnyObject)
    {
        PFUser.logOut()
        
        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("iPhoneStoryboard")
    }
    
    

}
