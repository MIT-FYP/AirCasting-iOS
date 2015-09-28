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
    
    //    var audioRecorder:AVAudioRecorder!
    var decibel:Float = 0
    var timer = NSTimer()
    var timerDB = NSTimer()
    var recording: Bool = false
    
    let dbManager = DBManager()
    
    var uuid: NSObject = NSObject()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println("IN APP")
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
        
        uuid = NSUUID().UUIDString
        recording = true
//        updateMeasurement()
        if recording{
            timerDB = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateMeasurement"), userInfo: nil, repeats: true)
        } else{
            timerDB.invalidate()
        }
        
    }
    
    func updateMeasurement(){
        //Inserting value into database
        if !dbManager.insertMeasurements("\(uuid)", device: "phone_microphone", decibels: decibel) {
            println("AirCasting: Error in inserting measurements into database")
        } else{
            println("AirCasting: Successfully inserted measurements into database")
        }
    }
    
    
    //    func recordDecibels() -> Float{
    //
    //        var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
    //        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
    //        audioSession.setActive(true, error: nil)
    //
    //        var documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
    //        var str =  documents.stringByAppendingPathComponent("recordTest.caf")
    //        var url = NSURL.fileURLWithPath(str as String)
    //
    //        var recordSettings = [AVFormatIDKey:kAudioFormatAppleIMA4,
    //            AVSampleRateKey:44100.0,
    //            AVNumberOfChannelsKey:1,
    //            AVEncoderBitRateKey:16,
    //            //            AVLinearPCMBitDepthKey:16,
    //            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue,
    //            //            AVLinearPCMIsBigEndianKey:false,
    //            //            AVLinearPCMIsFloatKey:false
    //
    //        ]
    //
    //        //        println("url : \(url)")
    //        var error: NSError?
    //
    //        audioRecorder = AVAudioRecorder(URL:url, settings: recordSettings as [NSObject : AnyObject] , error: &error)
    //        if let e = error {
    //            println(e.localizedDescription)
    //        } else {
    //
    //            audioRecorder.meteringEnabled = true
    //            audioRecorder.record()
    //            audioRecorder.updateMeters()
    //            decibel = audioRecorder.peakPowerForChannel(0)
    //            decibel += 120
    //            println("DB = \(decibel)")
    //
    //        }
    //        return decibel
    //    }
    
    @IBAction func toMap(sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let mapView = storyBoard.instantiateViewControllerWithIdentifier("MapView") as! MapViewController
        
        mapView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(mapView,  animated: true, completion: nil)
    }
    
    @IBAction func toGraph(sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let graphView = storyBoard.instantiateViewControllerWithIdentifier("GraphView") as! GraphViewController
        
        graphView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(graphView,  animated: true, completion: nil)
    }
}

