//
//  DecibelMeter.swift
//  AirC
//
//  Created by Renji Harold on 19/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation
import AVFoundation

class DecibelMeter {
    
    var audioRecorder:AVAudioRecorder!
    var decibel:Float = 0
    
    func recordDecibels() -> Float{
        
        var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        audioSession.setActive(true, error: nil)
        
        var documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        var str =  documents.stringByAppendingPathComponent("recordTest.caf")
        var url = NSURL.fileURLWithPath(str as String)
        
        var recordSettings = [AVFormatIDKey:kAudioFormatAppleIMA4,
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:1,
            AVEncoderBitRateKey:16,
            //            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue,
            //            AVLinearPCMIsBigEndianKey:false,
            //            AVLinearPCMIsFloatKey:false
            
        ]
        
        //        println("url : \(url)")
        var error: NSError?
        
        audioRecorder = AVAudioRecorder(URL:url, settings: recordSettings as [NSObject : AnyObject] , error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            
            audioRecorder.meteringEnabled = true
            audioRecorder.record()
            audioRecorder.updateMeters()
            decibel = audioRecorder.peakPowerForChannel(0)
            decibel += 120
//            println("DB = \(decibel)")
            
        }
        return decibel
    }
    
}

