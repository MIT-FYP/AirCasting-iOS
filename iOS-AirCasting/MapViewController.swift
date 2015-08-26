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
    
    // Variables for background
    
    var redLegendView = UIImageView(image: UIImage(named: "redLegend"))
    var orangeLegendView = UIImageView(image: UIImage(named: "orangeLegend"))
    var yellowLegendView = UIImageView(image: UIImage(named: "yellowLegend"))
    var greenLegendView = UIImageView(image: UIImage(named: "greenLegend"))
    
    var startCordX: CGFloat = 0
    var startCordY: CGFloat = 70
    
    var decibel:Float = 0
    var timer = NSTimer()
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    //Object for Calculating Height
    var objBgHeight = BackgroundCustomization()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateLabel"), userInfo: nil, repeats: true)
    }
    
    @IBAction func displayLegendMenu(sender: UITapGestureRecognizer) {
        updateBackground()
        updateLegendMenu.hidden = false
        
    }
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
//        mapLabel.text = "\(locations[0])"
        myLocations.append(locations[0] as! CLLocation)
        
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
    
    func updateLabel(){
        var objDecibel = DecibelMeter()
        decibel = objDecibel.recordDecibels()
        
        decibelLabel.text = "\(Int(round(decibel)))"
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
                
                println("array size = 9")
                
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
            } else{
                println("bgValues.txt File corrupt")
            }
            
            
            
//            setBackground(redHt.doubleValue, orangeHt: orangeHt.doubleValue, yellowHt: yellowHt.doubleValue, greenHt: greenHt.doubleValue)
            
//            println("RH: \(redHt)")
//            println("OH: \(orangeHt)")
//            println("YH: \(yellowHt)")
//            println("GH: \(greenHt)")
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
        
        var storeHt = BackgroundCustomization()
        storeHt.storeSetting(redHt, orangeHt: orangeHt, yellowHt: yellowHt, greenHt: greenHt, redTxt: redTxt, orangeTxt: orangeTxt, yellowTxt: yellowTxt, greenTxt: greenTxt, blackTxt: blackTxt)
        
//        setBackground(redHt, orangeHt: orangeHt, yellowHt: yellowHt, greenHt: greenHt)
    }
    
    //    @IBAction func display(sender: UIButton) {
    //        println("hello")
    //        sensorMenu.hidden = false
    //    }
    //
    //    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    //        sensorMenu.hidden = true
    //    }
    
}
