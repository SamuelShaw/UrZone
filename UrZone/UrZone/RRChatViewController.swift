//
//  RRChatViewController.swift
//  UrZone
//
//  Created by Samuel Shaw on 1/5/16.
//  Copyright © 2016 The Iron Yard. All rights reserved.
//

import UIKit
import Parse

class RRChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    
    @IBOutlet weak var rrTableView: UITableView!
    
    @IBOutlet weak var rrMessageTextfield: UITextField!
    
    
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
        self.rrTableView.delegate = self
        self.rrTableView.dataSource = self
        
        self.rrMessageTextfield.delegate = self
        
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
            //if closestBeacon.proximity == .Far
            //if closestBeacon.minor == 51273 && closestBeacon.rssi < -70
   

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
    
    func update() {
        let query = PFQuery(className: "RestroomChat")
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
        rrTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("RRChatCell") as! RRTableViewCell
        cell.rrChatUser.text = currentData[indexPath.row]["username"]!
        cell.rrChatText.text = currentData[indexPath.row]["text"]!
        
        let radius = cell.rrRoundView.frame.height / 2
        cell.rrRoundView.layer.cornerRadius = radius
        
        let hue = 1 / CGFloat(currentData.count) * CGFloat(indexPath.row)
        cell.rrRoundView.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        cell.rrChatText.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        
        return cell
    }
    
    @IBAction func rrSend() {
        let obj = PFObject(className: "RestroomChat")
        currentSessionUN = (PFUser.currentUser()?.username)!      //(PFusernameString as? String)!
        obj.setObject(currentSessionUN, forKey: "username")
        
        obj.setObject(rrMessageTextfield.text!, forKey: "text")
        try! obj.save()
        rrMessageTextfield.text = ""
        self.view.endEditing(true)
    }
}
