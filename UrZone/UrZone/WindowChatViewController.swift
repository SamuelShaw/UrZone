//
//  WindowChatViewController.swift
//  UrZone
//
//  Created by Samuel Shaw on 1/5/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import UIKit
import Parse

class WindowChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    
    @IBOutlet weak var windowTableView: UITableView!
    
    @IBOutlet weak var windowMessageTextfield: UITextField!
    
    
    var counterNumber = 0
    
    var username : String?
    
    var updateTimer = NSTimer()
    
    let updateDelay = 1.0
    
    var currentData: [[String: String]] = []
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "EstimoteBeacons")

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.windowTableView.delegate = self
        self.windowTableView.dataSource = self
        
        self.windowMessageTextfield.delegate = self
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(updateDelay, target: self, selector: "update", userInfo: nil, repeats: true)
        
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse)
        {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startRangingBeaconsInRegion(region)
        
        print ("\(PFusernameString)")
        
        // Resign Keyboard
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "didTapView")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        print(beacons)
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0)
        {
            let closestBeacon = knownBeacons[0] as CLBeacon
            if closestBeacon.rssi < -70
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Detect")
                    self.presentViewController(viewController, animated: true, completion: nil) })
            }
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}

