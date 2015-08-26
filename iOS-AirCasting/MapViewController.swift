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

class MapViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapLabel: UILabel!
    //    @IBOutlet weak var sensorMenu: UIView!
    
    @IBOutlet weak var decibelLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    
    var decibel:Float = 0
    var timer = NSTimer()
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        mapLabel.text = "\(locations[0])"
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
    //    @IBAction func display(sender: UIButton) {
    //        println("hello")
    //        sensorMenu.hidden = false
    //    }
    //
    //    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    //        sensorMenu.hidden = true
    //    }
    
}
