//
//  FileIO.swift
//  AirC
//
//  Created by Renji Harold on 24/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation

class FileIO{
    
    func writeToDocumentsFile(fileName:String,value:String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let path = documentsPath.stringByAppendingPathComponent(fileName)
        var error:NSError?
        value.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
    }
    
    func readFromDocumentsFile(fileName:String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let path = documentsPath.stringByAppendingPathComponent(fileName)
        var checkValidation = NSFileManager.defaultManager()
        var error:NSError?
        var file:String
        
        if checkValidation.fileExistsAtPath(path) {
            file = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil) as! String
        } else {
            file = "*ERROR* \(fileName) does not exist."
        }
        
        return file
    }
    
}