//
//  RESTServices.swift
//  iOS-AirCasting
//
//  Created by Renji Harold on 24/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation

public class RESTServices{
    
    var SERVER_URL: String = ""
    let SESSIONS_DB = "aircasting_database/"
    let USERS_DB = "aircasting_users/"
    let UUID_COUCHDB = "_uuids/"
    let SESSIONS_URL = "aircasting_database/_design/find_record/_view/find_sessions"
    let USERS_URL = "aircasting_users/_design/find_record/_view/find_username?key="
    
    //Function to insert data into Couchdb
    func put(params : NSMutableDictionary, url : String, putCompleted : (succeeded: Bool, msg: String) -> ()) {
        println("Inside put method")
        var err: NSError?
        
        //Set request parameters
        var session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "PUT"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            
            if let error = error {
                println("Error: \(error)")
            }
            
            //Print body of data returned from server
            //            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //            println("Body: \(strData)")
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary!
            
            
            if let httpResponse = response as? NSHTTPURLResponse {
                println("Responde Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 201 {
                    var ok: Bool = false
                    if let d = json as? [String: AnyObject] {
                        if let
                            _ok = d["ok"] as? Bool{
                                ok = _ok
                        }
                    }
                    putCompleted(succeeded: ok, msg: "Post successful")
                } else {
                    
                    putCompleted(succeeded: false, msg: "Error code: \(httpResponse.statusCode)")
                    
                }
            }
            
        })
        
        task.resume()
    }
    
    func get(url : String, getCompleted : (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> ()) {
        println("Inside get method")
        var err: NSError?
        
        //Set request parameters
        var session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            
            if let error = error {
                println("Error: \(error)")
            }
            
            //Print body of data returned from server
            //            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //            println("Body: \(strData)")
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            //            println(err!.localizedDescription)
            
            if let httpResponse = response as? NSHTTPURLResponse {
                println("Responde Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                    getCompleted(succeeded: true, msg: "Post successful", jsonResponse: json!)
                } else {
                    getCompleted(succeeded: false, msg: "Error code: \(httpResponse.statusCode)", jsonResponse: json!)
                    
                }
            }
            
        })
        
        task.resume()
    }
    
    func getUUID() -> String {
        
        SERVER_URL = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/"
        let UUIDUrl = SERVER_URL + UUID_COUCHDB
        var uuid: String = ""
        
        get(UUIDUrl) { (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> () in
            
            if(succeeded) {
                println("json: \(jsonResponse)")
                
                var arrUuid: NSMutableArray = NSMutableArray()
                if let d = jsonResponse as? [String: AnyObject] {
                    if let
                        _uuid = d["uuids"] as? NSMutableArray{
                            arrUuid = _uuid
                    }
                }
                
                println("uuid: \(arrUuid[0])")
                uuid = arrUuid[0] as! String
            }
            else {
                println("uuid: Error")
                uuid = "error"
            }
        }
        return uuid
    }
    
    
    func getUsername(keyValue: String) -> String {
        
        SERVER_URL = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/"
        let sessionsUrl = SERVER_URL + USERS_URL + "%22" + keyValue + "%22"
        var user: String = ""
        var username: String = ""
        
        get(sessionsUrl) { (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> () in
            
            if(succeeded) {
                println("json: \(jsonResponse)")
                
                var arrUser: NSMutableArray = NSMutableArray()
                if let d = jsonResponse as? [String: AnyObject] {
                    if let
                        _user = d["rows"] as? NSMutableArray{
                            arrUser = _user
                    }
                }
                username = arrUser[0].valueForKey("value") as! String
            }
            else {
                println("uuid: Error")
                //uuid = "error"
            }
        }
        
        return username
    }
    
    //Inserts session data
    func putData(params: NSMutableDictionary, parentID: String) -> Bool {
        
        SERVER_URL = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/"
        var success: Bool = false
        var uuid: String = ""
        
        if parentID == "none" {
            uuid = generateUUID()
        } else{
            uuid = parentID
        }
                println("UU:\(uuid)")
        let airCastingSessionUrl = SERVER_URL + SESSIONS_DB + uuid
//        let newurl = "http://115.146.85.75:5984/albums/" + uuid
    
        put(params, url: airCastingSessionUrl) { (succeeded: Bool, msg: String) -> () in
            if(succeeded) {
                success = true
            }
            else {
                println("Error: \(msg)")
            }
        }
        println("success: \(success)")

        return success
    }
    
    func generateUUID() -> String{
        return ("\(NSUUID().UUIDString)")
    }
    
    //Create New User
    
    func createUser(params: NSMutableDictionary, uuid: String) -> Bool {
        
        SERVER_URL = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/"
        var success: Bool = false
        //var uuid = generateUUID()
        println("UU:\(uuid)")
        let airCastingSessionUrl = SERVER_URL + USERS_DB + uuid
        put(params, url: airCastingSessionUrl) { (succeeded: Bool, msg: String) -> () in
            if(succeeded) {
                success = true
            }
            else {
                println("Error: \(msg)")
            }
        }
        println("success: \(success)")
        
        return success
    }

}
