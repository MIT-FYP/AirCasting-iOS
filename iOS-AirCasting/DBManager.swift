//
//  DBManager.swift
//  iOS-AirCasting
//
//  Created by Renji Harold on 28/09/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation

class DBManager {
    
    var acDatabase: FMDatabase = FMDatabase()
    
    func createDB() -> Bool{
      
        println("AirCasting: Creating database and table")
        
        //Creating SQLlite database
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let path = documentsFolder.stringByAppendingPathComponent("aircasting.sqlite")
        acDatabase = FMDatabase(path: path)
        
        if !acDatabase.open() {
            println("AirCasting: Unable to open database")
            return false
        }
        
        //Creating table - measurements
        if !acDatabase.executeUpdate("create table if not exists measurements(session_id text, device text, decibel float)", withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        return true
        
    }
    
    func insertMeasurements(sessionId: String, device: String, decibels: Float) -> Bool {
        
        println("AirCasting: Inserting measurements into database")
        
//        if let rs = acDatabase.executeQuery("select * from aircasting", withArgumentsInArray: nil){
//           println("record count: \(rs.columnCount())")
//        } else {
//            println("select failed: \(acDatabase.lastErrorMessage())")
//        }
        
        if !acDatabase.executeUpdate("insert into measurements (session_id, device, decibel) values (?, ?, ?)", withArgumentsInArray: [sessionId, device, decibels]) {
            println("AirCasting: DB Error: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        return true
    }
    
    
}