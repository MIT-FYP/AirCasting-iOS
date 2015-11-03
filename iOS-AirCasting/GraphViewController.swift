//
//  GraphViewController.swift
//  AirC
//
//  Created by Renji Harold on 5/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit
import CoreLocation

class GraphViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var recordBtn: UIButton!
    // Line chart
    let frameDistance:CGFloat = 50
    var location = CGPoint(x: 0, y: 0)
    var xStartLineChart = CGFloat(0)
    var yStartLineChart = CGFloat(0)
    var xEndLineChart = CGFloat(0)
    var yEndLineChart = CGFloat(0)
    var sequenceIndex = 0
    var previousSensorValue = CGFloat(0);
    var currentSensorValue = CGFloat(0);
    @IBOutlet weak var lineChartView: UIScrollView!
    
    
    
    // Legend
    @IBOutlet weak var legendBarLabel: UIImageView!
    @IBOutlet weak var updateLegendMenu: UIView!
    
    // More button
    
    @IBOutlet weak var moreButton: UIImageView!
    @IBOutlet weak var sessionsListButton: UIButton!
    @IBOutlet weak var settingsMenuButton: UIButton!
    
    //Clocks
    @IBOutlet weak var startClock: UILabel!
    @IBOutlet weak var finishClock: UILabel!
    
    
    // Text Fields
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var orangeTextField: UITextField!
    @IBOutlet weak var yellowTextField: UITextField!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var blackTextField: UITextField!
  
    
    @IBOutlet weak var orangeSlider: UISlider!
    @IBOutlet weak var yellowSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    
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
    
    // Round labels
    
    @IBOutlet weak var avgMeasurementLabel: UILabel!
    @IBOutlet weak var nowMeasurementLabel: UILabel!
    @IBOutlet weak var peakMeasurementLabel: UILabel!
    
    
    @IBOutlet weak var sensorLabel: UILabel!
    @IBOutlet weak var avgSensorLabel: UILabel!
    @IBOutlet weak var peakSensorLabel: UILabel!
    
    // Session Informaion View
    
    @IBOutlet weak var sessionTitleView: UIView!
    @IBOutlet weak var sessionTitle: UITextField!
    @IBOutlet weak var startStreamingButton: UIButton!
    
    @IBOutlet weak var saveOnly: UIButton!
    
    
    
    // Picker Menu
    
    @IBOutlet weak var sensorParameterMenu: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerDataSource = ["Humidity - AirBeam-RH (%)", "Particulate Matter - AirBeam-PM (ug/m3)", "Sound Level - Phone Microphone (DB)", "Temperature - AirBeam-C (C)"];
    
    
    
    // Variables for background
    var redLegendView = UIImageView(image: UIImage(named: "redLegend"))
    var orangeLegendView = UIImageView(image: UIImage(named: "orangeLegend"))
    var yellowLegendView = UIImageView(image: UIImage(named: "yellowLegend"))
    var greenLegendView = UIImageView(image: UIImage(named: "greenLegend"))
    
    var startCordX: CGFloat = 0
    var startCordY: CGFloat = 52
    
    // Sensor variables
    
    var decibel:Float = 0
    var avgDecibel: Float = 0
    var sumDecibel: Float = 0
    var peakDecibel: Float = 0
    
    var humidity:Float = 0
    //var previousHumidity = 0
    var avgHumidity: Float = 0
    var sumHumidity: Float = 0
    var peakHumidity: Float = 0
    
    var particulateMatter:Float = 0
    //var previousParticulateMatter = 0
    var avgParticulateMatter: Float = 0
    var sumParticulateMatter: Float = 0
    var peakParticulateMatter: Float = 0
    
    var temperature:Float = 0
    //var previousTemperature = 0
    var avgTemperature: Float = 0
    var sumTemperature: Float = 0
    var peakTemperature: Float = 0

    
    var measurementCount: Float = 0
    
    var timer = NSTimer()
    var timerDB = NSTimer()
    
    var uuid: NSObject = NSObject()
    let dbManager = DBManager()
    let objDecibel = DecibelMeter()
    let restRequest = RESTServices()


    
    //Object for Calculating Height
    var objBgHeight = BackgroundCustomization()
    
    var updateSensorLabel: String = "decibel"
    //let bleConnectorObj = AirCastingBLEController()
    var manager:CLLocationManager!

    // Clean Route parameters
    
    @IBOutlet weak var cleanRouteParameters: UIView!
    
    @IBOutlet weak var sourceAddress: UITextField!
    
    @IBOutlet weak var destinationAddress: UITextField!
    
    @IBOutlet weak var pollutionType: UITextField!
    
    
///////////////////////////////////////////////////////////////////////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        lineChartView.delegate = self
    
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //bleConnectorObj.initializeBLE()
        
        //Initialize X and  Y for line chart
        
        println("Start Y :" , CGRectGetMaxY(lineChartView.frame)) // will return the bottommost y coordinate of the view
        println("Start X :" ,CGRectGetMinX(lineChartView.frame))// will return the leftmost x coordinate of the view
        
        xStartLineChart = CGRectGetMinX(lineChartView.frame)
        yStartLineChart = CGRectGetMaxY(lineChartView.frame)
        currentSensorValue = CGRectGetMaxY(lineChartView.frame)
        
        //start = CGPoint(x: CGRectGetMinX(lineChartView.frame), y: CGRectGetMaxY(lineChartView.frame))
        
        var defaultRowIndex = find(pickerDataSource,"Sound Level - Phone Microphone (DB)")
        if(defaultRowIndex == nil) { defaultRowIndex = 0 }
        pickerView.selectRow(defaultRowIndex!, inComponent: 0, animated: false)
        decibel = objDecibel.recordDecibels()
        sensorLabel.text = "\(Int(round(decibel)))"
        
        sensorParameterMenu.hidden = true
        lineChartView.hidden = true
        sessionsListButton.hidden = true
        settingsMenuButton.hidden = true
        
        updateLegendMenu.hidden = true
        redTextField.delegate = self
        orangeTextField.delegate = self
        yellowTextField.delegate = self
        greenTextField.delegate = self

        //Populate saved values from file
        updateBackground()
        
        updateSensorLabel = "decibel"
        
        //Initiate timer to display clocks
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: ("updateClocks"), userInfo: nil, repeats: true)
        
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
        
        sessionTitleView.hidden = true
        cleanRouteParameters.hidden = true
        saveOnly.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        println("Graphview: View disappear")
    }

    
    @IBAction func saveChangesButton(sender: UIButton) {

        //Calculate the heights of background row based on threshold values set in menu
        let bgHeights = objBgHeight.calculateHeights(redTextField.text.toInt()!, orange: orangeTextField.text.toInt()!, yellow: yellowTextField.text.toInt()!, green: greenTextField.text.toInt()!, black: blackTextField.text.toInt()!)
        
        println("ht: \(bgHeights.redHt)")
        println("ht: \(bgHeights.orangeHt)")
        println("ht: \(bgHeights.yellowHt)")
        println("ht: \(bgHeights.greenHt)")
        
        //Draw background
        setBackground(bgHeights.redHt, orangeHt: bgHeights.orangeHt, yellowHt: bgHeights.yellowHt, greenHt: bgHeights.greenHt)
        
        //Hide menu
        updateLegendMenu.hidden = true
        //lineChartView.hidden = false
        
    }
    
    @IBAction func restoreDefaultButton(sender: UIButton) {
        updateLegendMenu.hidden = true
        
        //Set default values
        restoreDefault()
    }
    
    @IBAction func displayLegendMenu(sender: UITapGestureRecognizer) {

        updateLegendMenu.hidden = false
        lineChartView.hidden = true
    }
    
    @IBAction func toDashboard(sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let dashboard = storyBoard.instantiateViewControllerWithIdentifier("Dashboard") as! DashboardController
        
        dashboard.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(dashboard,  animated: true, completion: nil)
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

        
        self.view.endEditing(true)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        //Draw again when orientation changes
        updateBackground()
        
    }
    
    //Update textfield when slider value changes
    @IBAction func updateTextFields(sender: UISlider) {
        
        switch sender.tag {
        case 1: orangeTextField.text = "\(Int(orangeSlider.value))"
        case 2: yellowTextField.text = "\(Int(yellowSlider.value))"
        case 3: greenTextField.text = "\(Int(greenSlider.value))"
        default: println("Invalid Slider error - GraphView")
        }
        
    }

    //Update slider when textfield changes and update thresholds
    @IBAction func endTxtUpdate(sender: UITextField) {

        updateThresholds()
    }
    
    //Update threshold when slider value changes
    @IBAction func endSliderUpdate(sender: UISlider) {

        updateThresholds()
    }
    
    //Update threshold values based on changes
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
    
    // Clocks
    func updateClocks()
        
    {
        startClock.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle:NSDateFormatterStyle.NoStyle , timeStyle: NSDateFormatterStyle.MediumStyle)
        
        finishClock.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle:NSDateFormatterStyle.NoStyle , timeStyle: NSDateFormatterStyle.MediumStyle)
    }
    
    
    //Retrieve saved values from file
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
                
                setBackground(redHt.doubleValue, orangeHt: orangeHt.doubleValue, yellowHt: yellowHt.doubleValue, greenHt: greenHt.doubleValue)
            } else{
                println("GraphView:updatBackground - bgValues.txt File corrupt")
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
    
        setBackground(redHt, orangeHt: orangeHt, yellowHt: yellowHt, greenHt: greenHt)
    }
    
    //Set minimums and maximums for sliders
    func setSliderMinMax(maximum: Float, minimum: Float){

        orangeSlider.maximumValue = maximum
        orangeSlider.minimumValue = minimum
        
        yellowSlider.maximumValue = maximum
        yellowSlider.minimumValue = minimum
        
        greenSlider.maximumValue = maximum
        greenSlider.minimumValue = minimum
        
    }
    
    //Draws the background
    func setBackground(redHt: Double, orangeHt: Double, yellowHt: Double, greenHt: Double){
        
        var legendWidth = view.frame.size.width
        var legendHeight = view.bounds.size.height - 100
        
        var redLegendWidth = legendWidth
        var redLegendHeight = (view.bounds.size.height-100) * CGFloat(redHt)
        
        var orangeLegendWidth = legendWidth
        var orangeLegendHeight = (view.bounds.size.height-100) * CGFloat(orangeHt)
        
        var yellowLegendWidth = legendWidth
        var yellowLegendHeight = (view.bounds.size.height-100) * CGFloat(yellowHt)
        
        var greenLegendWidth = legendWidth
        var greenLegendHeight = (view.bounds.size.height-100) * CGFloat(greenHt)
        
        
        var redYAxis = startCordY
        var orangeYAxis = redYAxis + redLegendHeight
        var yellowYAxis = orangeYAxis + orangeLegendHeight
        var greenYAxis = yellowYAxis + yellowLegendHeight
        
        redLegendView.frame = CGRect(x: startCordX, y: redYAxis, width: redLegendWidth, height: redLegendHeight)
        view.addSubview(redLegendView)
        view.sendSubviewToBack(redLegendView)
        
        orangeLegendView.frame = CGRect(x: startCordX, y: orangeYAxis, width: orangeLegendWidth, height: orangeLegendHeight)
        view.addSubview(orangeLegendView)
        view.sendSubviewToBack(orangeLegendView)
        
        yellowLegendView.frame = CGRect(x: startCordX, y: yellowYAxis, width: yellowLegendWidth, height: yellowLegendHeight)
        view.addSubview(yellowLegendView)
        view.sendSubviewToBack(yellowLegendView)
        
        greenLegendView.frame = CGRect(x: startCordX, y: greenYAxis, width: greenLegendWidth, height: greenLegendHeight)
        view.addSubview(greenLegendView)
        view.sendSubviewToBack(greenLegendView)
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

    }
    
    func recordData(){
        
        
        if DecibelMeter.isRecording{
            DecibelMeter.isRecording = false
        } else{
            DecibelMeter.isRecording = true
        }
        
        if recordBtn.titleLabel?.text == "Start Recording"{
            
            lineChartView.hidden = false
            
            uuid = NSUUID().UUIDString
            saveOnly.hidden = false
            recordBtn.setTitle("Stop Recording", forState: UIControlState.Normal)
            recordBtn.setImage(UIImage(named: "StopRecord"), forState: UIControlState.Normal)
            
            if UploadType.currentSelection == "Stream" {
                uploadParentSessionDoc()
            }
            
            //Initiate the timer to start storing the measurements
            timerDB = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateMeasurement"), userInfo: nil, repeats: true)
            
            
        } else{
            
            lineChartView.hidden = true
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
        
        //println("Avg decibel = \(avgDecibel)")
        //println("Peak decibel = \(peakDecibel)")
        
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

        
        previousSensorValue = currentSensorValue
        currentSensorValue = CGRectGetMaxY(lineChartView.frame)-((CGFloat(decibel)-CGFloat(20))*7.0)
        updateLineChart()
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
        lineChartView.hidden = true
        
        
    }
    
    func updateLineChart(){
        if(sequenceIndex < 1000){
            
            xStartLineChart = 0
            yStartLineChart = previousSensorValue
            yEndLineChart = currentSensorValue
            plotNextLine()
        }
    }
    
    func plotNextLine(){
        
        let start = CGPoint(x: xStartLineChart, y: yStartLineChart)
        let end = CGPoint(x: frameDistance, y: yEndLineChart)
        let lineView = generateNextFrame(start: start,end: end)
        let numberOfExtraFrames = ceil(CGFloat(sequenceIndex) - floor(lineChartView.frame.width / frameDistance))
        if (numberOfExtraFrames > 0 ){
            lineChartView.contentSize = CGSizeMake(numberOfExtraFrames  * frameDistance + lineChartView.frame.size.width, lineChartView.frame.size.height)
        }
        lineChartView.addSubview(lineView)
        self.lineChartView.scrollRectToVisible(lineView.frame, animated: true)
        sequenceIndex += 1


    }
    
    func generateNextFrame(#start:CGPoint,end:CGPoint) -> LineGraphView{
        let frame = CGRectMake(frameDistance * (CGFloat(sequenceIndex)), 0, frameDistance, lineChartView.frame.size.height)
        let lineView = LineGraphView(start: start, end: end, frame: frame)
        lineView.backgroundColor = UIColor.clearColor()
        return lineView
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
