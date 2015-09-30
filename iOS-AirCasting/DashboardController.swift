//
//  ViewController.swift
//  AirC
//
//  Created by Renji Harold on 5/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit
import AVFoundation

class DashboardController: UIViewController {
    
    @IBOutlet weak var decibelLabel: UILabel!
    @IBOutlet weak var avgDecibelLabel: UILabel!
    @IBOutlet weak var peakDecibelLabel: UILabel!
    
    //    var audioRecorder:AVAudioRecorder!
    var decibel:Float = 0
    var avgDecibel: Float = 0
    var sumDecibel: Float = 0
    var peakDecibel: Float = 0
    var measurementCount: Float = 0
    
    var timer = NSTimer()
    var timerDB = NSTimer()
    
    let dbManager = DBManager()
    
    var uuid: NSObject = NSObject()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println("viewDidLoad: App launch")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabel(){
        var objDecibel = DecibelMeter()
        decibel = objDecibel.recordDecibels()
        
        decibelLabel.text = "\(Int(round(decibel)))"
    }
    
    
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
}

