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
    let dbQueries: DBQueries = DBQueries()
    
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
        
        if !createTables() {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        } else{
            println("AirCasting: Database tables created successfully")
        }
        
        //drop tables
//        
//        if !acDatabase.executeUpdate("drop table parent_session", withArgumentsInArray: nil) {
//            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
//        }
//        else
//        {
//            println("AirCasting: Database tables deleted successfully")
//        }
//        
//        if !acDatabase.executeUpdate("drop table measurements_sessions", withArgumentsInArray: nil) {
//            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
//        }
//        else
//        {
//            println("AirCasting: Database tables deleted successfully")
//        }
        
        return true
        
    }
    
    //    func insertMeasurements(sessionId: String, device: String, decibels: Float) -> Bool {
    
    func insertParent(data: [AnyObject]) -> Bool {
        
        println("AirCasting: Inserting Parent doc into database")
        
        if !acDatabase.executeUpdate(dbQueries.insert_parent_session, withArgumentsInArray: data) {
            println("AirCasting: DB Error: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        return true
    
    }
    func insertMeasurements(data: [AnyObject]) -> Bool {
        
        println("AirCasting: Inserting measurements into database")
        
        if !acDatabase.executeUpdate(dbQueries.insert_measurements_sessions, withArgumentsInArray: data) {
            println("AirCasting: DB Error: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        return true
    }
    
    func queryDB(){
        
        println("AirCasting: QUERYDB")
        
        if !acDatabase.executeUpdate("drop table notes", withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
        }
        
        if let rs = acDatabase.executeQuery("select * from measurements_sessions", withArgumentsInArray: nil) {
            while rs.next() {
                let x = rs.stringForColumnIndex(0)
                let y = rs.stringForColumnIndex(1)
                let z = rs.stringForColumnIndex(2)
                let x1 = rs.stringForColumnIndex(3)
                let y1 = rs.stringForColumnIndex(4)
                let z1 = rs.stringForColumnIndex(5)
                let x2 = rs.stringForColumnIndex(6)
                let y2 = rs.stringForColumnIndex(7)
                let z2 = rs.stringForColumnIndex(8)
                println("x = \(x); y = \(y); z = \(z); x = \(x1); y = \(y1); z = \(z1); x = \(x2); y = \(y2); z = \(z2)")
            }
        } else {
            println("select failed: \(acDatabase.lastErrorMessage())")
        }
    }
    
    func retrieveMeasurements() -> Array<NSMutableDictionary> {
        println("AirCasting: retrieveMeasurements")
        
        var measurementArray = [NSMutableDictionary]()
        
        if let rs = acDatabase.executeQuery("select * from measurements_sessions", withArgumentsInArray: nil) {
            while rs.next() {
                var measurementDic = NSMutableDictionary()
                measurementDic.setObject(String(rs.stringForColumnIndex(0)), forKey: "id")
                measurementDic.setObject(String(rs.stringForColumnIndex(1)), forKey: "decibel_value")
                measurementDic.setObject(String(rs.stringForColumnIndex(2)), forKey: "temperature_value")
                measurementDic.setObject(String(rs.stringForColumnIndex(3)), forKey: "particulate_matter_value")
                measurementDic.setObject(String(rs.stringForColumnIndex(4)), forKey: "humidity_value")
                measurementDic.setObject(String(rs.stringForColumnIndex(5)), forKey: "latitude")
                measurementDic.setObject(String(rs.stringForColumnIndex(6)), forKey: "longitude")
                measurementDic.setObject(String(rs.stringForColumnIndex(7)), forKey: "created_at")
                measurementDic.setObject(String(rs.stringForColumnIndex(8)), forKey: "stream_id")
                measurementArray.append(measurementDic)
            }
        } else {
            println("select failed: \(acDatabase.lastErrorMessage())")
        }
        
        return measurementArray
    }
    
    func retrieveUserSessions(id: String) -> Array<NSMutableDictionary> {
        println("AirCasting: retrieveParent")
        
        var sessionArray = [NSMutableDictionary]()
        
        println("From DBManager\(id)")
        println("select * from parent_session where user_id=\'\(id)\'")
        
        if let rs = acDatabase.executeQuery("select * from parent_session where user_id=\'\(id)\'", withArgumentsInArray: nil) {
            while rs.next() {
                var parentDic = NSMutableDictionary()
                parentDic.setObject(String(rs.stringForColumnIndex(0)), forKey: "date")
                parentDic.setObject(String(rs.stringForColumnIndex(1)), forKey: "created_at")
                parentDic.setObject(String(rs.stringForColumnIndex(2)), forKey: "updated_at")
                parentDic.setObject(String(rs.stringForColumnIndex(3)), forKey: "username")
                parentDic.setObject(String(rs.stringForColumnIndex(4)), forKey: "user_id")
                parentDic.setObject(String(rs.stringForColumnIndex(5)), forKey: "text")
                parentDic.setObject(String(rs.stringForColumnIndex(6)), forKey: "session_id")
                parentDic.setObject(String(rs.stringForColumnIndex(7)), forKey: "photo_file_name")
                parentDic.setObject(String(rs.stringForColumnIndex(8)), forKey: "photo_content_type")
                parentDic.setObject(String(rs.stringForColumnIndex(8)), forKey: "photo_file_size")
                parentDic.setObject(String(rs.stringForColumnIndex(8)), forKey: "photo_updated_at")
                parentDic.setObject(String(rs.stringForColumnIndex(8)), forKey: "sensor_package_name")
                parentDic.setObject(String(rs.stringForColumnIndex(8)), forKey: "phone_model")
                parentDic.setObject(String(rs.stringForColumnIndex(8)), forKey: "os_version")
                
                sessionArray.append(parentDic)
            }
        } else {
            println("select failed: \(acDatabase.lastErrorMessage())")
        }
        
        return sessionArray
    }

    func deleteSessions() {
        if !acDatabase.executeUpdate("DELETE FROM measurements_sessions", withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
        }
        
        if !acDatabase.executeUpdate("DELETE FROM parent_session", withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
        }
    }
    func createTables() -> Bool {
        
        println("AirCasting: createTables()")
        
        if !acDatabase.executeUpdate(dbQueries.create_parent_session, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_measurements_sessions, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_deleted_sessions, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_measurements, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_notes, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_regressions, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_sessions, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_streams, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_taggings, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_tags, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        if !acDatabase.executeUpdate(dbQueries.create_users, withArgumentsInArray: nil) {
            println("AirCasting: Failed to create table: \(acDatabase.lastErrorMessage())")
            return false
        }
        
        return true
    }
    
}