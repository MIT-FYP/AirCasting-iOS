//
//  MapViewController.swift
//  AirC
//
//  Created by Renji Harold on 13/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var location = CGPoint(x: 0, y: 0)
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var updateLegendMenu: UIView!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var recordBtn: UIButton!
    
    // More menu
    
    @IBOutlet weak var moreButton: UIImageView!
    @IBOutlet weak var sessionsListButton: UIButton!
    @IBOutlet weak var settingsMenuButton: UIButton!

    //Text Fields
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var orangeTextField: UITextField!
    @IBOutlet weak var yellowTextField: UITextField!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var blackTextField: UITextField!
    
    @IBOutlet weak var orangeSlider: UISlider!
    @IBOutlet weak var yellowSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    
    @IBOutlet weak var sensorLabel: UILabel!
    @IBOutlet weak var avgSensorLabel: UILabel!
    @IBOutlet weak var peakSensorLabel: UILabel!
    
    
    // Sensor measurement parameter menu
    
    @IBOutlet weak var sensorParameterMenu: UIView!    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerDataSource = ["Humidity - AirBeam-RH (%)", "Particulate Matter - AirBeam-PM (ug/m3)", "Sound Level - Phone Microphone (DB)", "Temperature - AirBeam-C (C)"];
    
    @IBOutlet weak var avgMeasurementLabel: UILabel!
    @IBOutlet weak var nowMeasurementLabel: UILabel!
    @IBOutlet weak var peakMeasurementLabel: UILabel!
    
    // Session Informaion View
    
    @IBOutlet weak var sessionTitleView: UIView!
    @IBOutlet weak var sessionTitle: UITextField!
    @IBOutlet weak var startStreamingButton: UIButton!
    
    @IBOutlet weak var saveOnly: UIButton!
    
    // Legend bar text fields
    
    @IBOutlet weak var mainThreshold1: UILabel!
    @IBOutlet weak var mainThreshold2: UILabel!
    @IBOutlet weak var mainThreshold3: UILabel!
    @IBOutlet weak var mainThreshold4: UILabel!
    @IBOutlet weak var mainThreshold5: UILabel!
    @IBOutlet weak var mainThreshold6: UILabel!
    @IBOutlet weak var mainThreshold7: UILabel!
    @IBOutlet weak var mainThreshold8: UILabel!
    @IBOutlet weak var mainThreshold9: UILabel!
    @IBOutlet weak var mainThreshold10: UILabel!

    
    // Variables for background
    
    var redLegendView = UIImageView(image: UIImage(named: "redLegend"))
    var orangeLegendView = UIImageView(image: UIImage(named: "orangeLegend"))
    var yellowLegendView = UIImageView(image: UIImage(named: "yellowLegend"))
    var greenLegendView = UIImageView(image: UIImage(named: "greenLegend"))
    
    var startCordX: CGFloat = 0
    var startCordY: CGFloat = 70
    
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
    
    var uuid: NSObject = NSObject()
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    //Object for Calculating Height
    var objBgHeight = BackgroundCustomization()
    let objDecibel = DecibelMeter()
    var updateSensorLabel: String = "decibel"
    
    //Load Saved Session View
    
    var plotSavedSession = false
    var sessionID: String = ""
    
    var plotCleanRoute = false
    var arrCleanRoute: Array<Node> = []
    
    var SERVER_URL: String = ""
    let SESSIONS_LatLong_URL = "aircasting_database/_design/find_record/_view/find_session_latlong?key="
    
    // Clean Route parameters
    
    @IBOutlet weak var cleanRouteParameters: UIView!
    
    @IBOutlet weak var sourceAddress: UITextField!
    
    @IBOutlet weak var destinationAddress: UITextField!
    
    @IBOutlet weak var pollutionType: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        var defaultRowIndex = find(pickerDataSource,"Sound Level - Phone Microphone (DB)")
        if(defaultRowIndex == nil) { defaultRowIndex = 0 }
        pickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
        
        sensorParameterMenu.hidden = true
        sessionsListButton.hidden = true
        settingsMenuButton.hidden = true
        
        println("viewDidLoad: App launch")
        
        decibel = objDecibel.recordDecibels()
        sensorLabel.text = "\(Int(round(decibel)))"
        
        updateLegendMenu.hidden = true
        redTextField.delegate = self
        orangeTextField.delegate = self
        yellowTextField.delegate = self
        greenTextField.delegate = self

        //        sensorMenu.hidden = true
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
//        println("lat: \(manager.location.coordinate.latitude)")
//        println("long: \(manager.location.coordinate.longitude)")

        
        
        //Setup our Map View
        mapView.delegate = self
        
        println("Check Map Selection: \(MapStyle.currentSelection)")
        
        if(MapStyle.currentSelection == "Standard")
        {
            println("I am Here: in Standard")
            mapView.mapType = MKMapType.Standard
        }
        else
        {
            println("I am Here: in Satelite")
            mapView.mapType = MKMapType.Satellite
        }
        
        
        mapView.showsUserLocation = true
        view.sendSubviewToBack(mapView)
        
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
        
        if(plotSavedSession == true)
        {
            //showSavedSession()
            getSessionLatLong(sessionID)
        }
        
        if plotCleanRoute {
            plotCleanRouteCoordinates()
        }
        
        sessionTitleView.hidden = true
        cleanRouteParameters.hidden = true
        saveOnly.hidden = true
        
        SERVER_URL = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/"
    }
    
    @IBAction func updateTextFields(sender: UISlider) {
        
        switch sender.tag {
        case 1: orangeTextField.text = "\(Int(orangeSlider.value))"
        case 2: yellowTextField.text = "\(Int(yellowSlider.value))"
        case 3: greenTextField.text = "\(Int(greenSlider.value))"
        default: println("Invalid Slider error - GraphView")
        }
    }
    
    @IBAction func endSliderUpdate(sender: UISlider) {
        
        updateThresholds()
    }
    
    @IBAction func endTextUpdate(sender: UITextField) {
        
        updateThresholds()
    }
    
    @IBAction func displayLegendMenu(sender: UITapGestureRecognizer) {
        updateBackground()
        updateLegendMenu.hidden = false
        
    }
    
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
//        mapLabel.text = "\(locations[0])"
        
        if DecibelMeter.isRecording {
            myLocations.append(locations[0] as! CLLocation)
            
            view.sendSubviewToBack(mapView)
            
            let spanX = 0.007
            let spanY = 0.007
            var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
            mapView.setRegion(newRegion, animated: true)
            
            if (myLocations.count > 1){
                var sourceIndex = myLocations.count - 1
                var destinationIndex = myLocations.count - 2
                
                let c1 = myLocations[sourceIndex].coordinate
                let c2 = myLocations[destinationIndex].coordinate
                var a = [c1, c2]
                var polyline = MKPolyline(coordinates: &a, count: a.count)
                mapView.addOverlay(polyline)
            }
        }
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }
    
    @IBAction func menuTap(sender: UITapGestureRecognizer) {
        
        if menuLabel.text == "New" {
            menuLabel.text = "Old"
        } else {
            menuLabel.text = "New"
        }
        println("Tapping")
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        var touch : UITouch! = touches.first as! UITouch
        
        sensorParameterMenu.hidden = true
        sessionsListButton.hidden = true
        settingsMenuButton.hidden = true
        cleanRouteParameters.hidden = true
        sessionTitleView.hidden = true

    }
    
    @IBAction func saveChangesButton(sender: UIButton) {
       
        //        var bgHeights: [Int] = []
        let bgHeights = objBgHeight.calculateHeights(redTextField.text.toInt()!, orange: orangeTextField.text.toInt()!, yellow: yellowTextField.text.toInt()!, green: greenTextField.text.toInt()!, black: blackTextField.text.toInt()!)
        
        println("ht: \(bgHeights.redHt)")
        println("ht: \(bgHeights.orangeHt)")
        println("ht: \(bgHeights.yellowHt)")
        println("ht: \(bgHeights.greenHt)")
        
        updateLegendMenu.hidden = true
    }
    
    @IBAction func restoreDefaultButton(sender: UIButton) {
        
        updateLegendMenu.hidden = true
        restoreDefault()
    }
    
    func updateThresholds(){
        
        println("redTextField.text: \(redTextField.text)")
        println("orangeTextField: \(orangeTextField.text)")
        println("yellowTextField: \(yellowTextField.text)")
        println("greenTextField: \(greenTextField.text)")
        println("blackTextField: \(blackTextField.text)")
        
        if redTextField.text.toInt() < orangeTextField.text.toInt() {
            orangeTextField.text = String(redTextField.text.toInt()! - 1)
        }
        if orangeTextField.text.toInt() < yellowTextField.text.toInt() {
            yellowTextField.text = String(orangeTextField.text.toInt()! - 1)
        }
        if yellowTextField.text.toInt() < greenTextField.text.toInt() {
            greenTextField.text = String(yellowTextField.text.toInt()! - 1)
        }
        if greenTextField.text.toInt() < blackTextField.text.toInt() {
            blackTextField.text = String(greenTextField.text.toInt()! - 1)
        }
        
        //Set minimums and maximums for sliders
        setSliderMinMax((redTextField.text as NSString).floatValue,
            minimum: (blackTextField.text as NSString).floatValue)
        
        orangeSlider.value = (orangeTextField.text as NSString).floatValue
        yellowSlider.value = (yellowTextField.text as NSString).floatValue
        greenSlider.value = (greenTextField.text as NSString).floatValue
        
        updateThresholdLabels()
        
    }
    
    @IBAction func toDashboard(sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let dashboard = storyBoard.instantiateViewControllerWithIdentifier("Dashboard") as! DashboardController
        
        dashboard.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(dashboard,  animated: true, completion: nil)
    }
    
    func updateBackground(){
        var objRead = FileIO()
        
        var htValues = objRead.readFromDocumentsFile("bgValues.txt")
        
        if htValues.lowercaseString.rangeOfString("error") != nil {
            
            restoreDefault()
            
        } else{
            
            var arrHt = split(htValues) {$0 == ","}
            
            if arrHt.count == 9 {
                
                var redHt = NSString(string: arrHt[0])
                var orangeHt = NSString(string: arrHt[1])
                var yellowHt = NSString(string: arrHt[2])
                var greenHt = NSString(string: arrHt[3])
                var redTxt = NSString(string: arrHt[4])
                var orangeTxt = NSString(string: arrHt[5])
                var yellowTxt = NSString(string: arrHt[6])
                var greenTxt = NSString(string: arrHt[7])
                var blackTxt = NSString(string: arrHt[8])
                
                redTextField.text = redTxt as String
                orangeTextField.text = orangeTxt as String
                yellowTextField.text = yellowTxt as String
                greenTextField.text = greenTxt as String
                blackTextField.text = blackTxt as String
                
                orangeSlider.value = orangeTxt.floatValue
                yellowSlider.value = yellowTxt.floatValue
                greenSlider.value = greenTxt.floatValue
                
                //Set minimums and maximums for sliders
                setSliderMinMax((redTextField.text as NSString).floatValue,
                    minimum: (blackTextField.text as NSString).floatValue)
                
                updateThresholdLabels()
            } else{
                println("bgValues.txt File corrupt")
            }
        }
    }
    
    func restoreDefault(){
        
        var redHt = 0.25
        var orangeHt = 0.125
        var yellowHt = 0.125
        var greenHt = 0.5
        var redTxt = 100
        var orangeTxt = 80
        var yellowTxt = 70
        var greenTxt = 60
        var blackTxt = 20
        
        redTextField.text = "\(redTxt)"
        orangeTextField.text = "\(orangeTxt)"
        yellowTextField.text = "\(yellowTxt)"
        greenTextField.text = "\(greenTxt)"
        blackTextField.text = "\(blackTxt)"
        
        orangeSlider.value = Float(orangeTxt)
        yellowSlider.value = Float(yellowTxt)
        greenSlider.value = Float(greenTxt)
        
        //Set minimums and maximums for sliders
        setSliderMinMax((redTextField.text as NSString).floatValue,
            minimum: (blackTextField.text as NSString).floatValue)
        
        updateThresholdLabels()
        
        var storeHt = BackgroundCustomization()
        storeHt.storeSetting(redHt, orangeHt: orangeHt, yellowHt: yellowHt, greenHt: greenHt, redTxt: redTxt, orangeTxt: orangeTxt, yellowTxt: yellowTxt, greenTxt: greenTxt, blackTxt: blackTxt)

    }
    
    //Set minimums and maximums for sliders
    func setSliderMinMax(maximum: Float, minimum: Float){
        
        //        println("maximum: \(maximum) minimum: \(minimum)")
        orangeSlider.maximumValue = maximum
        orangeSlider.minimumValue = minimum
        
        yellowSlider.maximumValue = maximum
        yellowSlider.minimumValue = minimum
        
        greenSlider.maximumValue = maximum
        greenSlider.minimumValue = minimum
        
    }
    
    func updateThresholdLabels(){
        
        mainThreshold1.text = blackTextField.text
        mainThreshold2.text = greenTextField.text
        mainThreshold3.text = yellowTextField.text
        mainThreshold4.text = orangeTextField.text
        mainThreshold5.text = redTextField.text
        
        mainThreshold6.text = blackTextField.text
        mainThreshold7.text = greenTextField.text
        mainThreshold8.text = yellowTextField.text
        mainThreshold9.text = orangeTextField.text
        mainThreshold10.text = redTextField.text
        
        
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
        
//        sessionTitleView.hidden = false
//        if DecibelMeter.isRecording{
//            DecibelMeter.isRecording = false
//        } else{
//            DecibelMeter.isRecording = true
//        }
//        
//        if sender.titleLabel?.text == "Start Recording"{
//            uuid = NSUUID().UUIDString
//            //            println(uuid)
//            sender.setTitle("Stop Recording", forState: UIControlState.Normal)
//            sender.setImage(UIImage(named: "StopRecord"), forState: UIControlState.Normal)
//            
//            //Initiate the timer to start storing the measurements
//            timerDB = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateMeasurement"), userInfo: nil, repeats: true)
//            
//        } else{
//            sender.setTitle("Start Recording", forState: UIControlState.Normal)
//            sender.setImage(UIImage(named: "StartRecord"), forState: UIControlState.Normal)
//            
//            //Terminate the timer and stop storing measurements
//            timerDB.invalidate()
//        }
    }
    
    func recordData(){
        if DecibelMeter.isRecording{
            DecibelMeter.isRecording = false
        } else{
            DecibelMeter.isRecording = true
        }
        
        if recordBtn.titleLabel?.text == "Start Recording"{
            
            uuid = NSUUID().UUIDString
            recordBtn.setTitle("Stop Recording", forState: UIControlState.Normal)
            recordBtn.setImage(UIImage(named: "StopRecord"), forState: UIControlState.Normal)
            saveOnly.hidden = false
            
            if UploadType.currentSelection == "Stream" {
                uploadParentSessionDoc()
            }
            
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
            
//            getSessions()
        }
    }
    
    func uploadParentSessionDoc(){
        
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        
        var parentDic = NSMutableDictionary()
        parentDic.setObject(uuid, forKey: "_id")
        parentDic.setObject(timestamp, forKey: "date")
        parentDic.setObject(timestamp, forKey: "created_at")
        parentDic.setObject(timestamp, forKey: "updated_at")
        parentDic.setObject(SignedInUser.userID, forKey: "user_id")
        parentDic.setObject(sessionTitle.text, forKey: "text")
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

    
    func updateLabel(){
        
        if(updateSensorLabel == "decibel")
        {
            var objDecibel = DecibelMeter()
            decibel = objDecibel.recordDecibels()
            sensorLabel.text = "\(Int(round(decibel)))"
        }
        
        if(updateSensorLabel == "humidity")
        {
            
            //decibelLabel.text = dropLast(dropLast(bleConnectorObj.humidity))
            
            var bleConnectorObj = AirCastingBLEController()
            
            if(bleConnectorObj.humidity != nil)
            {
                //var range = Range(start: 0,end: count(bleConnectorObj.humidity))
                humidity = (dropLast(dropLast(bleConnectorObj.humidity)) as NSString).floatValue
                sensorLabel.text = "\(Int(round(humidity)))"
            }
            else
            {
                sensorLabel.text = "\(Int(round(humidity)))"
                //humidity = 0.0
            }
            
        }
        
        if(updateSensorLabel == "pm")
        {
            var bleConnectorObj = AirCastingBLEController()
            //decibelLabel.text = "\(Int(round((NSString(string: dropLast(bleConnectorObj.particulateMatter))).doubleValue)))"
            if(bleConnectorObj.particulateMatter != nil)
            {
                particulateMatter = (dropLast(bleConnectorObj.particulateMatter) as NSString).floatValue
                //decibelLabel.text = "\(Int(round((NSString(string: dropLast(bleConnectorObj.particulateMatter))).doubleValue)))"
                sensorLabel.text = "\(Int(round(particulateMatter)))"
            }
            else
            {
                sensorLabel.text = "\(Int(round(particulateMatter)))"
                //particulateMatter = 0.0
            }
            
        }
        
        if(updateSensorLabel == "temperature")
        {
            var bleConnectorObj = AirCastingBLEController()
            
            if(bleConnectorObj.temperature != nil)
            {
                temperature = (dropLast(bleConnectorObj.temperature) as NSString).floatValue
                sensorLabel.text = "\(Int(round(temperature)))"
            }
            else
            {
                sensorLabel.text = "\(Int(round(temperature)))"
                //temperature = 0.0
            }
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
        
        if(updateSensorLabel == "decibel")
            
        {
            avgSensorLabel.text = "\(Int(round(avgDecibel)))"
            peakSensorLabel.text = "\(Int(round(peakDecibel)))"
        }
        
        if(updateSensorLabel == "humidity")
            
        {
            avgSensorLabel.text = "\(Int(round(avgHumidity)))"
            peakSensorLabel.text = "\(Int(round(peakHumidity)))"
        }
        
        
        if(updateSensorLabel == "pm")
            
        {
            avgSensorLabel.text = "\(Int(round(avgParticulateMatter)))"
            peakSensorLabel.text = "\(Int(round(peakParticulateMatter)))"
        }
        
        
        if(updateSensorLabel == "temperature")
            
        {
            avgSensorLabel.text = "\(Int(round(avgTemperature)))"
            peakSensorLabel.text = "\(Int(round(peakTemperature)))"
        }
        
        println("Avg decibel = \(avgDecibel)")
        println("Peak decibel = \(peakDecibel)")
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)

        if UploadType.currentSelection == "Stream" {
            
            var childUuid = NSUUID().UUIDString
            
            var measurementDic = NSMutableDictionary()
            measurementDic.setObject(childUuid, forKey: "_id")
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
            
            measurementDic.setObject(readings, forKey: "measurements")
            measurementDic.setObject(manager.location.coordinate.latitude, forKey: "latitude")
            measurementDic.setObject(manager.location.coordinate.longitude, forKey: "longitude")
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
    
    
    // UI Picker functions
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(row == 0)
        {
            //self.view.backgroundColor = UIColor.whiteColor();
            avgMeasurementLabel.text = "Avg RH"
            peakMeasurementLabel.text = "Peak RH"
            nowMeasurementLabel.text = "Now RH"
            updateSensorLabel = "humidity"
        }
        else if(row == 1)
        {
            //self.view.backgroundColor = UIColor.redColor();
            avgMeasurementLabel.text = "Avg PM"
            peakMeasurementLabel.text = "Peak PM"
            nowMeasurementLabel.text = "Now PM"
            updateSensorLabel = "pm"
        }
        else if(row == 2)
        {
            //self.view.backgroundColor =  UIColor.greenColor();
            avgMeasurementLabel.text = "Avg dB"
            peakMeasurementLabel.text = "Peak dB"
            nowMeasurementLabel.text = "Now dB"
            updateSensorLabel = "decibel"
        }
        else
        {
            //self.view.backgroundColor = UIColor.blueColor();
            avgMeasurementLabel.text = "Avg C"
            peakMeasurementLabel.text = "Peak C"
            nowMeasurementLabel.text = "Now C"
            updateSensorLabel = "temperature"
        }
    }

    @IBAction func openSensorParameterMenu(sender: AnyObject) {
        
        sensorParameterMenu.hidden = false
    }
    
    func plotCleanRouteCoordinates(){
        
        var counter = 0
        for point in arrCleanRoute {
            
            counter += 1
            
            if counter == arrCleanRoute.count {
                plotCoordinate(point.lat, lon: point.long, lastFlag: true)
            } else {
                plotCoordinate(point.lat, lon: point.long, lastFlag: false)

            }
            
        }
    }
    
    
    func plotCoordinate(lat:Double,lon:Double, lastFlag: Bool){
        
        println("\(lat),\(lon)")
        var location = CLLocationCoordinate2D(
                latitude: lat,
                longitude: lon
            )
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Latitude: \(round(lat)),Longitude: \(round(lon))"
        //println(String(format: "%.3f", totalWorkTimeInHours))
        annotation.subtitle = "coordinate"
        
        if(lastFlag==true)
        {
            var span = MKCoordinateSpanMake(0.11, 0.11)
            var region = MKCoordinateRegion(center: location, span: span)
        
            mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(annotation)
        }
        else
        {
            self.mapView.addAnnotation(annotation)
        }
    }
    
    // Get Sessions Latitude and Longitude
    
    func getSessionLatLong(keyValue: String){
        
        let sessionsUrl = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/" + SESSIONS_LatLong_URL + "%22" + keyValue + "%22"
        var session: String = ""
        var username: String = ""

        get(sessionsUrl) { (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> () in
            
            if(succeeded) {
                //println("json: \(jsonResponse)")
                
                var arrSession: NSMutableArray = NSMutableArray()
                if let d = jsonResponse as? [String: AnyObject] {
                    if let
                        _session = d["rows"] as? NSMutableArray{
                            arrSession = _session
                    }
                }
                var counter = 0
                var lastElementFlag = false
                
                for element in arrSession{
                    
                    counter = counter + 1
                    var sessionValue: AnyObject? = element.valueForKey("value")
                    var latitude = ((sessionValue?.valueForKey("latitude") as! String) as NSString).doubleValue
                    var longitude = ((sessionValue?.valueForKey("longitude") as! String) as NSString).doubleValue
                    
                    if(counter == arrSession.count)
                    {
                        lastElementFlag = true
                        self.plotCoordinate(latitude, lon: longitude,lastFlag: lastElementFlag)
                    }
                    else
                    {
                        lastElementFlag = false
                        self.plotCoordinate(latitude, lon: longitude,lastFlag: lastElementFlag)
                    }
                }
            }
            else {
                println("Session: Error")
                
            }
        }
    }
    
    func get(url : String, getCompleted : (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> ()) {
        //println("Inside get method")
        var err: NSError?
        
        //Set request parameters
        var session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println("Body: \(strData)")
            
            if let error = error {
                println("Error: \(error)")
            }
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            //            println(err!.localizedDescription)
            
            if let httpResponse = response as? NSHTTPURLResponse {
                //println("Responde Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                    getCompleted(succeeded: true, msg: "Post successful", jsonResponse: json!)
                } else {
                    getCompleted(succeeded: false, msg: "Error code: \(httpResponse.statusCode)", jsonResponse: json!)
                    
                }
            }
            
        })
        
        task.resume()
    }
    
    @IBAction func startStream(sender: UIButton) {
        
        sessionTitleView.hidden = true
        
        if UploadType.currentSelection == "Stream" {
            recordData()
        } else{
            uploadParentSessionDoc()
            storeDataLocalToRemote()
//            println("Saved Locally")
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
        
        shortestPath = astar.calculateShortestPath(map.startLocationLat, startLong: map.startLocationLong, goalLat: map.goalLocationLat, goalLong: map.goalLocationLong , pollution: pollution)
        
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
