//
//  ViewController.swift
//  AirC
//
//  Created by Renji Harold on 5/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import MapKit

class DashboardController: UIViewController, CLLocationManagerDelegate {
    
    var location = CGPoint(x: 0, y: 0)
    @IBOutlet weak var recordBtn: UIButton!
    
    // Decibel Labels
    
    @IBOutlet weak var decibelLabel: UILabel!
    @IBOutlet weak var avgDecibelLabel: UILabel!
    @IBOutlet weak var peakDecibelLabel: UILabel!
    
    // Humidity Labels
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var avgHumidityLabel: UILabel!
    @IBOutlet weak var peakHumidityLabel: UILabel!
    
    // Particulate Matter Labels
    
    @IBOutlet weak var particulateMatterLabel: UILabel!
    @IBOutlet weak var avgParticulateMatterLabel: UILabel!
    @IBOutlet weak var peakParticulateMatterLabel: UILabel!
    
    // Temperature Labels
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var avgTemperatureLabel: UILabel!
    @IBOutlet weak var peakTemperatureLabel: UILabel!
    
    
    // More Button
    
    @IBOutlet weak var moreButton: UIImageView!
    @IBOutlet weak var sessionsListButton: UIButton!
    @IBOutlet weak var settingsMenuButton: UIButton!
    
    @IBOutlet weak var startStreamingButton: UIButton!
    
    @IBOutlet weak var saveOnly: UIButton!
    
    // Sensor Labels
    
    // Sensor Variables
    
    var decibel:Float = 0
    var avgDecibel: Float = 0
    var sumDecibel: Float = 0
    var peakDecibel: Float = 0
    
    var humidity:Float = 0
    var avgHumidity: Float = 0
    var sumHumidity: Float = 0
    var peakHumidity: Float = 0
    
    var particulateMatter:Float = 0
    var avgParticulateMatter: Float = 0
    var sumParticulateMatter: Float = 0
    var peakParticulateMatter: Float = 0
    
    var temperature:Float = 0
    var avgTemperature: Float = 0
    var sumTemperature: Float = 0
    var peakTemperature: Float = 0
    
    var measurementCount: Float = 0
    
    var timer = NSTimer()
    var timerDB = NSTimer()
    
    let dbManager = DBManager()
    let restRequest = RESTServices()
    let objDecibel = DecibelMeter()
    
    var manager:CLLocationManager!

    
    var uuid: NSObject = NSObject()
    
    // BLE Connector
    
    static let bleConnectorObj = AirCastingBLEController()
    
    // Session Informaion View
    
    @IBOutlet weak var sessionTitleView: UIView!
    @IBOutlet weak var sessionTitle: UITextField!

    // Clean Route parameters
    
    @IBOutlet weak var cleanRouteParameters: UIView!
    
    @IBOutlet weak var sourceAddress: UITextField!
    
    @IBOutlet weak var destinationAddress: UITextField!
    
    @IBOutlet weak var pollutionType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Staring BLE
        
        //DashboardController.bleConnectorObj.initializeBLE()
        
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        // Initialize Decibel
        
        decibel = objDecibel.recordDecibels()
        decibelLabel.text = "\(Int(round(decibel)))"
        
        // Initialize Backend server settings
        
        var objRead = FileIO()
        
        var serverSettings = objRead.readFromDocumentsFile("backendServerSettings.txt")
        
        if serverSettings.lowercaseString.rangeOfString("error") != nil
        {
            println("No Initial server settings")
        }
        else
        {
            var currentSettings = split(serverSettings) {$0 == ","}
            println(currentSettings)
            
            BackendServerConfig.serverAddress = currentSettings[0]
            BackendServerConfig.serverPort = currentSettings[1]
        }

        
        // Intialize Map Settings
        
        var itemValues = objRead.readFromDocumentsFile("settingsValues.txt")
        
        if itemValues.lowercaseString.rangeOfString("error") != nil
        {
            println("No Initial data")
        }
        else
        {
            var selectedItems = split(itemValues) {$0 == ","}
            println(selectedItems)
            MapStyle.currentSelection = selectedItems[0]
            UploadType.currentSelection = selectedItems[1]
        }
        
        var signedUser = objRead.readFromDocumentsFile("signedInUser.txt")
        
        if signedUser.lowercaseString.rangeOfString("error") != nil
        {
            println("No Initial data")
        }
        else
        {
            var userDetails = split(signedUser) {$0 == ","}
            println(userDetails)
            println(userDetails)
            SignedInUser.userName = userDetails[0]
            SignedInUser.userID = userDetails[1]
            SignedInUser.signInFlag = ((userDetails[2]) as NSString).boolValue
        }
        
        println("viewDidLoad: App launch")
        
        //Creating SQLlite database
        if !dbManager.createDB() {
            println("AirCasting: Error in creating DB")
            exit(EXIT_FAILURE)
        } else{
            println("AirCasting: DB Created succcessfully")
        }
        
        if DecibelMeter.isRecording {
            recordBtn.setTitle("Stop Recording", forState: UIControlState.Normal)
            recordBtn.setImage(UIImage(named: "StopRecord"), forState: UIControlState.Normal)
        } else{
            timerDB.invalidate()
        }
        
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateLabel"), userInfo: nil, repeats: true)

        sessionsListButton.hidden = true
        settingsMenuButton.hidden = true
        sessionTitleView.hidden = true
        cleanRouteParameters.hidden = true
        saveOnly.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        println("Dashboard: View disappear")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        var touch : UITouch! = touches.first as! UITouch
        
        sessionsListButton.hidden = true
        settingsMenuButton.hidden = true
        cleanRouteParameters.hidden = true
        sessionTitleView.hidden = true
    }
    
    func updateLabel(){
        
        var sensorData = DashboardController.bleConnectorObj.sensorReading
        
        decibel = objDecibel.recordDecibels()
        
        decibelLabel.text = "\(Int(round(decibel)))"
        
        //var bleConnectorObj = AirCastingBLEController()
        
        if(DashboardController.bleConnectorObj.temperature != nil)
        {
            temperature = (dropLast(DashboardController.bleConnectorObj.temperature) as NSString).floatValue
            temperatureLabel.text = "\(Int(round(temperature)))"
        }
        else
        {
            temperatureLabel.text = "\(Int(round(temperature)))"
            
        }
        
        if(DashboardController.bleConnectorObj.particulateMatter != nil)
        {
            particulateMatter = (dropLast(DashboardController.bleConnectorObj.particulateMatter) as NSString).floatValue
            particulateMatterLabel.text = "\(Int(round(particulateMatter)))"
        }
        else
        {
            particulateMatterLabel.text = "\(Int(round(particulateMatter)))"
        }
        
        if(DashboardController.bleConnectorObj.humidity != nil)
        {
            humidity = (dropLast(dropLast(DashboardController.bleConnectorObj.humidity)) as NSString).floatValue
            humidityLabel.text = "\(Int(round(humidity)))"
        }
        else
        {
            humidityLabel.text = "\(Int(round(humidity)))"
        }

    }
    
    @IBAction func startRecording(sender: UIButton) {
        
        if SignedInUser.signInFlag == false {
            var alert = UIAlertView(title: "User not signed in.", message: "Please sign in to your profile.", delegate: nil, cancelButtonTitle: "Okay.")
//            alert.title = "User not signed in."
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })
            return
        }
        
        if UploadType.currentSelection == "Stream" && recordBtn.titleLabel?.text == "Start Recording" {
            sessionTitleView.hidden = false
        } else{
            recordData()
        }

    }
    
    func recordData(){
        if DecibelMeter.isRecording{
            DecibelMeter.isRecording = false
        } else{
            DecibelMeter.isRecording = true
        }
        
        if recordBtn.titleLabel?.text == "Start Recording"{
            
            uuid = NSUUID().UUIDString
            saveOnly.hidden = false
            recordBtn.setTitle("Stop Recording", forState: UIControlState.Normal)
            recordBtn.setImage(UIImage(named: "StopRecord"), forState: UIControlState.Normal)
            
            if UploadType.currentSelection == "Stream" {
                uploadParentSessionDoc()
            }
//            else
//            {
//                saveParentSessionDoc()
//            }
            
            
            //Initiate the timer to start storing the measurements
            timerDB = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateMeasurement"), userInfo: nil, repeats: true)
            
            
        } else{
            
            dbManager.queryDB()
            recordBtn.setTitle("Start Recording", forState: UIControlState.Normal)
            recordBtn.setImage(UIImage(named: "StartRecord"), forState: UIControlState.Normal)
            
            //Terminate the timer and stop storing measurements
            timerDB.invalidate()
            
            if UploadType.currentSelection == "Record" {
                startStreamingButton.setTitle("Save and Contribute", forState: UIControlState.Normal)
                saveOnly.hidden = false
                sessionTitleView.hidden = false
            }
            
            //getSessions()
        }
    }
    
    func uploadParentSessionDoc(){
        
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
    
        var parentDic = NSMutableDictionary()
//        parentDic.setObject(uuid, forKey: "_id")
        parentDic.setObject(timestamp, forKey: "date")
        parentDic.setObject(timestamp, forKey: "created_at")
        parentDic.setObject(timestamp, forKey: "updated_at")
        parentDic.setObject(String(SignedInUser.userName), forKey: "username")
        parentDic.setObject(String(SignedInUser.userID), forKey: "user_id")
        parentDic.setObject(String(sessionTitle.text), forKey: "text")
        parentDic.setObject(uuid, forKey: "session_id")
        parentDic.setObject("filename", forKey: "photo_file_name")
        parentDic.setObject("JPEG", forKey: "photo_content_type")
        parentDic.setObject("1MB", forKey: "photo_file_size")
        parentDic.setObject(timestamp, forKey: "photo_updated_at")
        parentDic.setObject("AirBeam", forKey: "sensor_package_name")
        parentDic.setObject("iPhone5", forKey: "phone_model")
        parentDic.setObject("iOS8", forKey: "os_version")
        
        var success = restRequest.putData(parentDic, parentID: uuid as! String)
        
        
    }
    
    func saveParentSessionDoc(title: String){
    
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        var parentArray = [AnyObject]()
        //        parentDic.setObject(uuid, forKey: "_id")
        //parentDic.setObject(timestamp, forKey: "date")
        parentArray.append(timestamp)
        //parentDic.setObject(timestamp, forKey: "created_at")
        parentArray.append(timestamp)
        //parentDic.setObject(timestamp, forKey: "updated_at")
        parentArray.append(timestamp)
        //parentDic.setObject(String(SignedInUser.userName), forKey: "username")
        parentArray.append(String(SignedInUser.userName))
        //parentDic.setObject(String(SignedInUser.userID), forKey: "user_id")
        parentArray.append(String(SignedInUser.userID))
        //parentDic.setObject(String(sessionTitle.text), forKey: "text")
        parentArray.append(String(title))
        //parentDic.setObject(uuid, forKey: "session_id")
        parentArray.append(uuid)
        //parentDic.setObject("filename", forKey: "photo_file_name")
        parentArray.append("filename")
        //parentDic.setObject("JPEG", forKey: "photo_content_type")
        parentArray.append("JPEG")
        //parentDic.setObject("1MB", forKey: "photo_file_size")
        parentArray.append("1MB")
        //parentDic.setObject(timestamp, forKey: "photo_updated_at")
        parentArray.append(timestamp)
        //parentDic.setObject("AirBeam", forKey: "sensor_package_name")
        parentArray.append("AirBeam")
        //parentDic.setObject("iPhone5", forKey: "phone_model")
        parentArray.append("iPhone4")
        //parentDic.setObject("iOS8", forKey: "os_version")
        parentArray.append("iOS8")
        
        println("Recording in progress")
        if !dbManager.insertParent(parentArray) {
            println("AirCasting: Error in inserting parent into database")
        } else{
            println("AirCasting: Successfully inserted parent record into database")
        }
        
    }
    
    func updateMeasurement(){
        
        if !DecibelMeter.isRecording{
            timerDB.invalidate()
            
            return
        }
        
        sumDecibel = sumDecibel + decibel
        sumHumidity = sumHumidity + humidity
        sumParticulateMatter = sumParticulateMatter + particulateMatter
        sumTemperature = sumTemperature + temperature
        measurementCount++
        
        avgDecibel = sumDecibel / measurementCount
        avgHumidity = sumHumidity / measurementCount
        avgParticulateMatter = sumParticulateMatter / measurementCount
        avgTemperature = sumTemperature / measurementCount
        
        if decibel > peakDecibel {
            peakDecibel = decibel
        }
        
        if humidity > peakHumidity {
            peakHumidity = humidity
        }
        
        if particulateMatter > peakParticulateMatter {
            peakParticulateMatter = particulateMatter
        }
        
        if temperature > peakTemperature {
            peakTemperature = temperature
        }
        
        
        avgDecibelLabel.text = "\(Int(round(avgDecibel)))"
        peakDecibelLabel.text = "\(Int(round(peakDecibel)))"
        
        avgHumidityLabel.text = "\(Int(round(avgHumidity)))"
        peakHumidityLabel.text = "\(Int(round(peakHumidity)))"
        
        avgParticulateMatterLabel.text = "\(Int(round(avgParticulateMatter)))"
        peakParticulateMatterLabel.text = "\(Int(round(peakParticulateMatter)))"
        
        avgTemperatureLabel.text = "\(Int(round(avgTemperature)))"
        peakTemperatureLabel.text = "\(Int(round(peakTemperature)))"

        
        println("Avg decibel = \(avgDecibel)")
        println("Peak decibel = \(peakDecibel)")
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)

        
        
        
//        var dataDic = NSMutableDictionary()
//        dataDic.setObject("luke", forKey: "user")
//        dataDic.setObject("decibel", forKey: "measurement_type")
//        dataDic.setObject(decibel, forKey: "measurement_value")

        
        if UploadType.currentSelection == "Stream" {
            
//            var childUuid = NSUUID().UUIDString
//            println("childUuid: \(childUuid)")
            
            var measurementDic = NSMutableDictionary()
//            measurementDic.setObject(childUuid, forKey: "_id")
            measurementDic.setObject(timestamp, forKey: "created_at")
            
            var decibelDic = NSMutableDictionary()
            decibelDic.setObject("dB", forKey: "unit_symbol")
            decibelDic.setObject(decibel, forKey: "measured_value")
            
            var temperatureDic = NSMutableDictionary()
            temperatureDic.setObject("C", forKey: "unit_symbol")
            temperatureDic.setObject(temperature, forKey: "measured_value")
            
            var particulateMatterDic = NSMutableDictionary()
            particulateMatterDic.setObject("ug/m3", forKey: "unit_symbol")
            particulateMatterDic.setObject(particulateMatter, forKey: "measured_value")
            
            var humidityDic = NSMutableDictionary()
            humidityDic.setObject("%", forKey: "unit_symbol")
            humidityDic.setObject(humidity, forKey: "measured_value")
            
            var readings = NSMutableDictionary()
            readings.setObject(decibelDic, forKey: "decibel")
            readings.setObject(temperatureDic, forKey: "temperature")
            readings.setObject(particulateMatterDic, forKey: "particulate_matter")
            readings.setObject(humidityDic, forKey: "humidity")
            
//            println(manager.location.coordinate.latitude)
            
            measurementDic.setObject(readings, forKey: "measurements")
            measurementDic.setObject(manager.location.coordinate.latitude, forKey: "latitude")
            measurementDic.setObject(manager.location.coordinate.longitude, forKey: "longitude")
            
//            measurementDic.setObject(111.11, forKey: "latitude")
//            measurementDic.setObject(222.22, forKey: "longitude")
            
            measurementDic.setObject(uuid, forKey: "ancestor_id")
            
            println("Streaming in progress")
            var success = restRequest.putData(measurementDic, parentID: "none")
            
        } else{
            
            var data = [AnyObject]()
            data.append(uuid)
            data.append(decibel)
            data.append(30)
            data.append(5)
            data.append(40)
            data.append(manager.location.coordinate.latitude)
            data.append(manager.location.coordinate.longitude)
            data.append(timestamp)
            data.append(uuid)
            
            println("Recording in progress")
            if !dbManager.insertMeasurements(data) {
                println("AirCasting: Error in inserting measurements into database")
            } else{
                println("AirCasting: Successfully inserted measurements into database")
            }
        }

    }
    
    //Navigate to Map Controller
    @IBAction func toMap(sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let mapView = storyBoard.instantiateViewControllerWithIdentifier("MapView") as! MapViewController
        
        mapView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(mapView,  animated: true, completion: nil)
    }
    
    //Navigate to Graph Controller
    @IBAction func toGraph(sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let graphView = storyBoard.instantiateViewControllerWithIdentifier("GraphView") as! GraphViewController
        
        graphView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(graphView,  animated: true, completion: nil)
    }
    
    @IBAction func openMoreMenu(sender: AnyObject) {
        
        sessionsListButton.hidden = false
        settingsMenuButton.hidden = false
        
    }
    
    @IBAction func sessionsAndSettings(sender: UIButton) {
        
        sessionsListButton.hidden = true
        settingsMenuButton.hidden = true
        
        if(sender.titleLabel!.text == "Sessions")
        {
            println("Open Sessions")
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let sessionsView = storyBoard.instantiateViewControllerWithIdentifier("SessionsView") as! SessionsViewController
            
            sessionsView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            self.presentViewController(sessionsView,  animated: true, completion: nil)
        }

        if(sender.titleLabel!.text == "Settings")
        {
            println("Open Settings")
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let settingsView = storyBoard.instantiateViewControllerWithIdentifier("SettingsMenu") as! SettingsViewController
            
            settingsView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            self.presentViewController(settingsView,  animated: true, completion: nil)
        }

    }
    
//    // Initializing Sessions
//    
//    func getSessions() {
//    
//        let sessionsUrl = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/" + USER_SESSIONS_URL + "%22" + SignedInUser.userName + "%22"
//        var sessions:String = ""
//        var sessionText: String = ""
//    
//        get(sessionsUrl) { (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> () in
//    
//            if(succeeded) {
//                //println("json: \(jsonResponse)")
//    
//                var arrSessions: NSMutableArray = NSMutableArray()
//                if let d = jsonResponse as? [String: AnyObject] {
//                    if let
//                        sessions = d["rows"] as? NSMutableArray{
//                            arrSessions = sessions
//                    }
//                }
//                
//                //println("Sessions: \(arrSessions)")
//                SessionsListViewController.sessionsListItems.removeAll(keepCapacity: true)
//                SessionsListViewController.itemSubtitles.removeAll(keepCapacity: true)
//                SessionsListViewController.sessionIDs.removeAll(keepCapacity: true)
//                println(arrSessions)
//                
//                for element in arrSessions{
//                    
//                    var sessionValue: AnyObject? = element.valueForKey("value")
//                    var userID = element.valueForKey("id") as! String
//                    var username = sessionValue?.valueForKey("user") as! String
//                    
//                    //var username = "Test"
//                    //self.getUsername(userID)
//                    
//                    var sessionDescription = sessionValue?.valueForKey("description") as! String
//                    SessionsListViewController.sessionsListItems.append(sessionDescription)
//                    SessionsListViewController.itemSubtitles.append(username)
//                    SessionsListViewController.sessionIDs.append(userID)
//                    println("UserName: \(username), Description: \(sessionDescription)")
//                }
//                
//            }
//            else {
//                println("Sessions: Error")
//                    //uuid = "error"
//            }
//        }
//    }

    
//    func get(url : String, getCompleted : (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> ()) {
//        println("Inside get method \(url)")
//        var err: NSError?
//        
//        //Set request parameters
//        var session = NSURLSession.sharedSession()
//        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
//        request.HTTPMethod = "GET"
//        
//        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//            //println("Response: \(response)")
//            
//            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            //println("Body: \(strData)")
//            
//            if let error = error {
//                println("Error: \(error)")
//            }
//            
//            //Print body of data returned from server
//            //            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            //            println("Body: \(strData)")
//            
//            var err: NSError?
//            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
//            
//            //            println(err!.localizedDescription)
//            
//            if let httpResponse = response as? NSHTTPURLResponse {
//                //println("Responde Code: \(httpResponse.statusCode)")
//                
//                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
//                    getCompleted(succeeded: true, msg: "Post successful", jsonResponse: json!)
//                } else {
//                    getCompleted(succeeded: false, msg: "Error code: \(httpResponse.statusCode)", jsonResponse: json!)
//                    
//                }
//            }
//            
//        })
//        
//        task.resume()
//    }
    

    @IBAction func startStream(sender: UIButton) {
        
        sessionTitleView.hidden = true
        if UploadType.currentSelection == "Stream" {
            recordData()
        } else{
            uploadParentSessionDoc()
            storeDataLocalToRemote()
            
            println("Saved Locally")
        }
        
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
            decibelDic.setObject(dict.objectForKey("decibel_value")!, forKey: "measured_value")
            
            var temperatureDic = NSMutableDictionary()
            temperatureDic.setObject("C", forKey: "unit_symbol")
            temperatureDic.setObject(dict.objectForKey("temperature_value")!, forKey: "measured_value")
            
            var particulateMatterDic = NSMutableDictionary()
            particulateMatterDic.setObject("ug/m3", forKey: "unit_symbol")
            particulateMatterDic.setObject(dict.objectForKey("particulate_matter_value")!, forKey: "measured_value")
            
            var humidityDic = NSMutableDictionary()
            humidityDic.setObject("%", forKey: "unit_symbol")
            humidityDic.setObject(dict.objectForKey("humidity_value")!, forKey: "measured_value")
            
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
        
    }
    
    @IBAction func cleanRoute(sender: UIButton) {
        
        cleanRouteParameters.hidden = false
    }
    
    
    @IBAction func findCleanRoute(sender: UIButton) {
        
        cleanRouteParameters.hidden = true
        
        if sourceAddress.text == "" || destinationAddress.text == "" {
            var alert = UIAlertView(title: "Clean Route", message: "Please enter source and destination", delegate: nil, cancelButtonTitle: "Okay.")
            //            alert.title = "Sign Out"
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })
            return
        }
        
        var source = sourceAddress.text
        var destination = destinationAddress.text
        var pollution = pollutionType.text
        
        var map = Map()
        map.initializeMap(source, destination: destination)

        var astar = AStarRouting(iMap: map)
        
        var shortestPath: [Node]!
        
        shortestPath = astar.calculateShortestPath(map.startLocationLat, startLong: map.startLocationLong, goalLat: map.goalLocationLat, goalLong: map.goalLocationLong, pollution: pollution)
        
        if let shortestPath = shortestPath {
            for coord in shortestPath {
                println("Step: \(coord.lat),\(coord.long)")
            }
            plotCleanRouteOnMap(shortestPath)
        } else {
            var alert = UIAlertView(title: "Clean Route", message: "No Path Exists.", delegate: nil, cancelButtonTitle: "Okay.")
//            alert.title = "Sign Out"
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })
        }
        
        
        
    }
    
    func plotCleanRouteOnMap(route: Array<Node>){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let mapView = storyBoard.instantiateViewControllerWithIdentifier("MapView") as! MapViewController
        
        mapView.plotCleanRoute = true
        mapView.arrCleanRoute = route
        
        mapView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(mapView,  animated: true, completion: nil)
        
    }
    
    
    @IBAction func saveToLocalDB(sender: UIButton) {
        sessionTitleView.hidden = true
        println("Saving parent doc to local db")
        saveParentSessionDoc(sessionTitle.text)
        
    }
    
}

