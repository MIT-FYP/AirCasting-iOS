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

class MapViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var mapLabel: UILabel!
    //    @IBOutlet weak var sensorMenu: UIView!
    
    
    @IBOutlet weak var updateLegendMenu: UIView!
    @IBOutlet weak var decibelLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    

    //Text Fields
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var orangeTextField: UITextField!
    @IBOutlet weak var yellowTextField: UITextField!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var blackTextField: UITextField!
    
    @IBOutlet weak var orangeSlider: UISlider!
    @IBOutlet weak var yellowSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    
    @IBOutlet weak var avgDecibelLabel: UILabel!
    @IBOutlet weak var peakDecibelLabel: UILabel!
    
    
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
    
    var decibel:Float = 0
    var avgDecibel: Float = 0
    var sumDecibel: Float = 0
    var peakDecibel: Float = 0
    var measurementCount: Float = 0
    
    var timer = NSTimer()
    var timerDB = NSTimer()
    
    let dbManager = DBManager()
    
    var uuid: NSObject = NSObject()
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    //Object for Calculating Height
    var objBgHeight = BackgroundCustomization()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("viewDidLoad: App launch")
        
        
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
        
        //Setup our Map View
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
        
        //Creating SQLlite database
        if !dbManager.createDB() {
            println("AirCasting: Error in creating DB")
            exit(EXIT_FAILURE)
        } else{
            println("AirCasting: DB Created succcessfully")
        }
        
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateLabel"), userInfo: nil, repeats: true)
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
        self.view.endEditing(true)
    }
    
    @IBAction func saveChangesButton(sender: UIButton) {
       
        //        var bgHeights: [Int] = []
        let bgHeights = objBgHeight.calculateHeights(redTextField.text.toInt()!, orange: orangeTextField.text.toInt()!, yellow: yellowTextField.text.toInt()!, green: greenTextField.text.toInt()!, black: blackTextField.text.toInt()!)
        
        println("ht: \(bgHeights.redHt)")
        println("ht: \(bgHeights.orangeHt)")
        println("ht: \(bgHeights.yellowHt)")
        println("ht: \(bgHeights.greenHt)")
        
//        setBackground(bgHeights.redHt, orangeHt: bgHeights.orangeHt, yellowHt: bgHeights.yellowHt, greenHt: bgHeights.greenHt)
        updateLegendMenu.hidden = true
        //        updateBackground()
        
    }
    
    @IBAction func restoreDefaultButton(sender: UIButton) {
        updateLegendMenu.hidden = true
        restoreDefault()
        //        defaultBackground()
    }
    
//    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        
//        updateBackground()
//        
//    }
    
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
                
//                println("array size = 9")
                
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
    
    //    @IBAction func display(sender: UIButton) {
    //        println("hello")
    //        sensorMenu.hidden = false
    //    }
    //
    //    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    //        sensorMenu.hidden = true
    //    }
    
    
    @IBAction func startRecording(sender: UIButton) {
        
        if sender.titleLabel?.text == "Start Recording"{
            uuid = NSUUID().UUIDString
            //            println(uuid)
            sender.setTitle("Stop Recording", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "StopRecord"), forState: UIControlState.Normal)
            
            //Initiate the timer to start storing the measurements
            timerDB = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateMeasurement"), userInfo: nil, repeats: true)
            
        } else{
            sender.setTitle("Start Recording", forState: UIControlState.Normal)
            sender.setImage(UIImage(named: "StartRecord"), forState: UIControlState.Normal)
            
            //Terminate the timer and stop storing measurements
            timerDB.invalidate()
        }
    }
    
    func updateLabel(){
        var objDecibel = DecibelMeter()
        decibel = objDecibel.recordDecibels()
        
        decibelLabel.text = "\(Int(round(decibel)))"
    }
    
    func updateMeasurement(){
        
        sumDecibel = sumDecibel + decibel
        measurementCount++
        
        avgDecibel = sumDecibel / measurementCount
        
        if decibel > peakDecibel {
            peakDecibel = decibel
        }
        
        avgDecibelLabel.text = "\(Int(round(avgDecibel)))"
        peakDecibelLabel.text = "\(Int(round(peakDecibel)))"
        
        println("Avg decibel = \(avgDecibel)")
        println("Peak decibel = \(peakDecibel)")
        
        //Inserting value into database
        if !dbManager.insertMeasurements("\(uuid)", device: "phone_microphone", decibels: decibel) {
            println("AirCasting: Error in inserting measurements into database")
        } else{
            println("AirCasting: Successfully inserted measurements into database")
        }
    }
    
}
