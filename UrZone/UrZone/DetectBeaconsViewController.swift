//
//  DetectBeaconsViewController.swift
//  UrZone
//
//  Created by Phillip English on 12/22/15.
//  Copyright © 2015 The Iron Yard. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import Parse


class DetectBeaconsViewController: UIViewController, CLLocationManagerDelegate
{
    
    var myZoneWav = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("myZoneWav", ofType: "wav")!)
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var proximityLabel: UILabel!
    
    @IBOutlet weak var minorLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "EstimoteBeacons")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse)
        {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startRangingBeaconsInRegion(region)
        
        do{
            try self.audioPlayer = AVAudioPlayer(contentsOfURL: myZoneWav, fileTypeHint: "wav")
        } catch {
            print ("Player not available")
        }
        self.audioPlayer.prepareToPlay()
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        print(beacons)
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if (knownBeacons.count > 0)
        {
            let closestBeacon = knownBeacons[0] as CLBeacon
            updateDistance(closestBeacon.proximity)
            self.minorLabel.text = "beacon minor is \(closestBeacon.minor.integerValue)"
            if closestBeacon.rssi > -40
            {
                if closestBeacon.minor == 22356
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatMain")
                        let navController = UINavigationController(rootViewController: viewController)
                        self.presentViewController(navController, animated: true, completion: nil) })
                }
                
                if closestBeacon.minor == 55866
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FridgeChat")
                        let navController = UINavigationController(rootViewController: viewController)
                        self.presentViewController(navController, animated: true, completion: nil) })
                }
                
                if closestBeacon.minor == 51273
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RestroomChat")
                        let navController = UINavigationController(rootViewController: viewController)
                        self.presentViewController(navController, animated: true, completion: nil) })
                }
                
                if closestBeacon.minor == 56045
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WindowChat")
                        let navController = UINavigationController(rootViewController: viewController)
                        self.presentViewController(navController, animated: true, completion: nil) })
                }
                
                if closestBeacon.minor == 24381
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SamsChat")
                        let navController = UINavigationController(rootViewController: viewController)
                        self.presentViewController(navController, animated: true, completion: nil) })
                }
            }
        }
        else
        {
            updateDistance(.Unknown)
        }
    }
    
    //experimenting with code from a tutorial here - Phil
    //test test test test
    //testagain
    func updateDistance(distance: CLProximity)
    {
        UIView.animateWithDuration(0.8) { [unowned self] in
            switch distance {
            case .Unknown:
                self.view.backgroundColor = UIColor.grayColor()
                self.proximityLabel.text = "UNKNOWN"
                
            case .Far:
                self.view.backgroundColor = UIColor.blueColor()
                self.proximityLabel.text = "FAR"
                
            case .Near:
                self.view.backgroundColor = UIColor.orangeColor()
                self.proximityLabel.text = "NEAR"
                
            case .Immediate:
                self.view.backgroundColor = UIColor.redColor()
                self.proximityLabel.text = "Bingo!"
                //self.audioPlayer.play()
                
                
                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    
//                    let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatMain")
//                    self.presentViewController(viewController, animated: true, completion: nil) })
                
                    
          
                
                
            }
        }
    }
    
    
    @IBAction func signOutButtonPressed(sender: AnyObject)
    {
        PFUser.logOut()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        print("Sign Out Successful")
    }
    
    
}
