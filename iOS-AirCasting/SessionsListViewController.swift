//
//  SessionsListViewController.swift
//  iOS-AirCasting
//
//  Created by Akmal Hossain on 29/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit

class SessionsListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    static var remoteSessionsListItems: [String] = [""]
    static var remoteItemSubtitles: [String] = [""]
    static var remoteSessionIDs:[String] = [""]
    
    static var localSessionsListItems: [String] = [""]
    static var localItemSubtitles: [String] = [""]
    static var localSessionIDs:[String] = [""]
    
    
    var itemName = NSString()
    let dbManager = DBManager()
    let restRequest = RESTServices()
    let objDecibel = DecibelMeter()
//    var acDatabase: FMDatabase = FMDatabase()
    
    // Initialize Sessions

    @IBOutlet weak var sessionsListView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    @IBOutlet weak var syncButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        sessionsListView.delegate = self
        sessionsListView.dataSource = self
        
        syncButton.enabled = false
        syncButton.tintColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var rowCount = 0
        
        switch itemName{
            
        case "synced":

            navigationBar.title = "Synced Sessions"
            rowCount = SessionsListViewController.remoteSessionsListItems.count
            
        case "saved":
            
            syncButton.enabled      = true
            syncButton.tintColor    = nil
            navigationBar.title = "Saved Sessions"
            rowCount = SessionsListViewController.localSessionsListItems.count
            
        default:
            println("Invalid Settings Option")
            
        }

        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let myCell: UITableViewCell = sessionsListView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        switch itemName{
            
        case "synced":
            
            myCell.textLabel?.text = SessionsListViewController.remoteSessionsListItems[indexPath.row]
            myCell.detailTextLabel?.text = SessionsListViewController.remoteItemSubtitles[indexPath.row]
            
        case "saved":
            
            myCell.textLabel?.text = SessionsListViewController.localSessionsListItems[indexPath.row]
            myCell.detailTextLabel?.text = SessionsListViewController.localItemSubtitles[indexPath.row]

            
        default:
            println("Invalid Settings Option")
            
        }

        return myCell
        
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        var itemSelected = SessionsListViewController.remoteSessionsListItems[indexPath.row]
        //println(itemSelected)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var selectedItem = NSString(string: (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)
        //println(selectedItem)
        var id = SessionsListViewController.remoteSessionIDs[indexPath.row]
        //println(id)
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        plotSessionOnMap(id)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    @IBAction func returnToSessionsView(sender: AnyObject) {
        
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let sessionsView = storyBoard.instantiateViewControllerWithIdentifier("SessionsView") as! SessionsViewController
        
        sessionsView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(sessionsView,  animated: true, completion: nil)

    }
    
    func plotSessionOnMap(id: String){
    
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let mapView = storyBoard.instantiateViewControllerWithIdentifier("MapView") as! MapViewController

        mapView.plotSavedSession = true
        mapView.sessionID = id
        
        mapView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(mapView,  animated: true, completion: nil)

    }
    
    @IBAction func syncSessions(sender: UIBarButtonItem) {
        
        var currentUserName = SignedInUser.userName
        var currentUserId = SignedInUser.userID
        
        println(currentUserId)
        
        println("From: Local DB \(currentUserName),\(currentUserId)")
        
        if !dbManager.createDB() {
            println("AirCasting: Unable to open database")
        }
        
        var savedSessionArray = [NSMutableDictionary]()
        savedSessionArray = dbManager.retrieveUserSessions(currentUserId)
        
        println(savedSessionArray.count)
        
        
        for element in savedSessionArray{
            
            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
            var parentDic = NSMutableDictionary()
            //        parentDic.setObject(uuid, forKey: "_id")
            parentDic.setObject((element.valueForKey("date")) as! String, forKey: "date")
            parentDic.setObject((element.valueForKey("created_at")) as! String, forKey: "created_at")
            parentDic.setObject((element.valueForKey("updated_at")) as! String, forKey: "updated_at")
            parentDic.setObject((element.valueForKey("username")) as! String, forKey: "username")
            parentDic.setObject((element.valueForKey("user_id")) as! String, forKey: "user_id")
            parentDic.setObject((element.valueForKey("text")) as! String, forKey: "text")
            parentDic.setObject((element.valueForKey("session_id")) as! String, forKey: "session_id")
            parentDic.setObject("filename", forKey: "photo_file_name")
            parentDic.setObject("JPEG", forKey: "photo_content_type")
            parentDic.setObject("1MB", forKey: "photo_file_size")
            parentDic.setObject((element.valueForKey("photo_updated_at")) as! String, forKey: "photo_updated_at")
            parentDic.setObject("AirBeam", forKey: "sensor_package_name")
            parentDic.setObject("iPhone5", forKey: "phone_model")
            parentDic.setObject("iOS8", forKey: "os_version")
        
            var success = restRequest.putData(parentDic, parentID: (element.valueForKey("session_id")) as! String)
            
        }

        storeDataLocalToRemote()
        
        //println("Sessions: \(arrSessions)")
        SessionsListViewController.localSessionsListItems.removeAll(keepCapacity: true)
        SessionsListViewController.localItemSubtitles.removeAll(keepCapacity: true)
        SessionsListViewController.localSessionIDs.removeAll(keepCapacity: true)
        
    }
    
    func storeDataLocalToRemote() {
        
        println("retrieving data to store")
        
        var measurementArray = dbManager.retrieveMeasurements()
        
        for dict in measurementArray {
            
            var childUuid = NSUUID().UUIDString
            
            var measurementDic = NSMutableDictionary()
            //            measurementDic.setObject(childUuid, forKey: "_id")
            measurementDic.setObject(dict.objectForKey("created_at")!, forKey: "created_at")
            
            var decibelDic = NSMutableDictionary()
            decibelDic.setObject("dB", forKey: "unit_symbol")
            decibelDic.setObject((dict.objectForKey("decibel_value") as! NSString).floatValue, forKey: "measured_value")
            
            var temperatureDic = NSMutableDictionary()
            temperatureDic.setObject("C", forKey: "unit_symbol")
            temperatureDic.setObject((dict.objectForKey("temperature_value") as! NSString).floatValue, forKey: "measured_value")
            
            var particulateMatterDic = NSMutableDictionary()
            particulateMatterDic.setObject("ug/m3", forKey: "unit_symbol")
            particulateMatterDic.setObject((dict.objectForKey("particulate_matter_value") as! NSString).floatValue, forKey: "measured_value")
            
            var humidityDic = NSMutableDictionary()
            humidityDic.setObject("%", forKey: "unit_symbol")
            humidityDic.setObject((dict.objectForKey("humidity_value") as! NSString).floatValue, forKey: "measured_value")
            
            var readings = NSMutableDictionary()
            readings.setObject(decibelDic, forKey: "decibel")
            readings.setObject(temperatureDic, forKey: "temperature")
            readings.setObject(particulateMatterDic, forKey: "particulate_matter")
            readings.setObject(humidityDic, forKey: "humidity")
            
            measurementDic.setObject(readings, forKey: "measurements")
            measurementDic.setObject(dict.objectForKey("latitude")!, forKey: "latitude")
            measurementDic.setObject(dict.objectForKey("longitude")!, forKey: "longitude")
            measurementDic.setObject(dict.objectForKey("stream_id")!, forKey: "ancestor_id")
            
            restRequest.putData(measurementDic, parentID: "none")
            
        }
        
        dbManager.deleteSessions()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let sessionsView = storyBoard.instantiateViewControllerWithIdentifier("SessionsView") as! SessionsViewController
        
        sessionsView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(sessionsView,  animated: true, completion: nil)
        
    }
}
