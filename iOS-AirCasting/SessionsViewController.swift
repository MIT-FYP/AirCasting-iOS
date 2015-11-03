//
//  SessionsViewController.swift
//  iOS-AirCasting
//
//  Created by Akmal Hossain on 3/11/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit

class SessionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sessions: [String] = ["Synced Sessions", "Saved Sessions"]
    var sessionsSubtitles: [String] = ["Sessions from remote database", "Sessions from local database"]
    
    var SERVER_URL: String = ""
    let SESSIONS_URL = "aircasting_database/_design/find_record/_view/find_sessions"
    let USER_SESSIONS_URL = "aircasting_database/_design/find_record/_view/find_user_sessions?key="
    let USERS_URL = "aircasting_users/_design/find_record/_view/find_username?key="

    @IBOutlet weak var sessionsView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getRemoteDBSessions()
        getLocalDBSessions()
        
        if(SignedInUser.signInFlag == false)
        {
            var alert = UIAlertView(title: "Failed!", message: "Please Sign in to load sessions", delegate: nil, cancelButtonTitle: "Okay.")
            alert.title = "Sessions List Display"
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })
        }
        
        sessionsView.delegate = self
        sessionsView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sessions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let myCell: UITableViewCell = sessionsView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        myCell.textLabel?.text = sessions[indexPath.row]
        myCell.detailTextLabel?.text = sessionsSubtitles[indexPath.row]
        
        return myCell
        
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        var itemSelected = sessions[indexPath.row]
        println(itemSelected)
        
        println("Open Sessions")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let sessionsListView = storyBoard.instantiateViewControllerWithIdentifier("SessionsList") as! SessionsListViewController
        
        if(itemSelected == "Synced Sessions")
        {
            sessionsListView.itemName = "synced"
        }
        else
        {
            sessionsListView.itemName = "saved"
        }
        
        sessionsListView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(sessionsListView,  animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var selectedItem = NSString(string: (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }

    @IBAction func returnToDashboard(sender: UIBarButtonItem) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let dashboard = storyBoard.instantiateViewControllerWithIdentifier("Dashboard") as! DashboardController
        
        dashboard.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(dashboard,  animated: true, completion: nil)
    }
    
    // Loading Remote Sessions
    
    func getRemoteDBSessions() {
        
        if(SignedInUser.signInFlag == true)
        {
        
            let sessionsUrl = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/" + USER_SESSIONS_URL + "%22" + SignedInUser.userName + "%22"
            var sessions:String = ""
            var sessionText: String = ""
        
            get(sessionsUrl) { (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> () in
            
                if(succeeded) {
                    //println("json: \(jsonResponse)")
                
                    var arrSessions: NSMutableArray = NSMutableArray()
                    if let d = jsonResponse as? [String: AnyObject] {
                        if let
                            sessions = d["rows"] as? NSMutableArray{
                                arrSessions = sessions
                        }
                    }

                
                    //println("Sessions: \(arrSessions)")
                    SessionsListViewController.remoteSessionsListItems.removeAll(keepCapacity: true)
                    SessionsListViewController.remoteItemSubtitles.removeAll(keepCapacity: true)
                    SessionsListViewController.remoteSessionIDs.removeAll(keepCapacity: true)
                    println(arrSessions)
                
                    for element in arrSessions{
                    
                        var sessionValue: AnyObject? = element.valueForKey("value")
                        var userID = element.valueForKey("id") as! String
                        var username = sessionValue?.valueForKey("user") as! String
                    
                        //var username = "Test"
                        //self.getUsername(userID)
                    
                        var sessionDescription = sessionValue?.valueForKey("description") as! String
                        SessionsListViewController.remoteSessionsListItems.append(sessionDescription)
                        SessionsListViewController.remoteItemSubtitles.append(username)
                        SessionsListViewController.remoteSessionIDs.append(userID)
                        println("UserName: \(username), Description: \(sessionDescription)")
                    }
                
                }
                else {
                    println("Sessions: Error")
                    //uuid = "error"
                }
            }
        }
        else
        {
            //println("Sessions: \(arrSessions)")
            SessionsListViewController.remoteSessionsListItems.removeAll(keepCapacity: true)
            SessionsListViewController.remoteItemSubtitles.removeAll(keepCapacity: true)
            SessionsListViewController.remoteSessionIDs.removeAll(keepCapacity: true)

        }
    }
    
    func get(url : String, getCompleted : (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> ()) {
        println("Inside get method \(url)")
        var err: NSError?
        
        //Set request parameters
        var session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println("Body: \(strData)")
            
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
                //println("Responde Code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                    getCompleted(succeeded: true, msg: "Post successful", jsonResponse: json!)
                } else {
                    getCompleted(succeeded: false, msg: "Error code: \(httpResponse.statusCode)", jsonResponse: json!)
                    
                }
            }
            
        })
        
        task.resume()
    }
    
    // Loading Local Sessions
    
    func getLocalDBSessions() {
        
        let localDBObj = DBManager()
        
        if !localDBObj.createDB() {
            println("AirCasting: Unable to open database")
        }
        else
        {
            if(SignedInUser.signInFlag == true)
            {
                var currentUserName = SignedInUser.userName
                var currentUserId = SignedInUser.userID
                
                println(currentUserId)
                
                println("From: Local DB \(currentUserName),\(currentUserId)")
                
                var savedSessionArray = [NSMutableDictionary]()
                savedSessionArray = localDBObj.retrieveUserSessions(currentUserId)
                
                println(savedSessionArray.count)
                
                //println("Sessions: \(arrSessions)")
                SessionsListViewController.localSessionsListItems.removeAll(keepCapacity: true)
                SessionsListViewController.localItemSubtitles.removeAll(keepCapacity: true)
                SessionsListViewController.localSessionIDs.removeAll(keepCapacity: true)

                
                for element in savedSessionArray{
                
                    SessionsListViewController.localSessionsListItems.append((element.valueForKey("text")) as! String)
                    SessionsListViewController.localItemSubtitles.append((element.valueForKey("username")) as! String)
                    SessionsListViewController.localSessionIDs.append((element.valueForKey("user_id")) as! String)
                    //println(element.valueForKey("username"))
                }
                
                
            }
            else
            {
                //println("Sessions: \(arrSessions)")
                SessionsListViewController.localSessionsListItems.removeAll(keepCapacity: true)
                SessionsListViewController.localItemSubtitles.removeAll(keepCapacity: true)
                SessionsListViewController.localSessionIDs.removeAll(keepCapacity: true)
            }

        }
    }
}
