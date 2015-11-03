//
//  SettingsItemViewController.swift
//  iOS-AirCasting
//
//  Created by Akmal Hossain on 24/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit

class SettingsItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let profileItems = ["Sign in","Create a new profile", "Forgot password"]
    let signedUser = [SignedInUser.userName]
    let mapItems = ["Standard", "Satellite"]
    let uploadItems = ["Record", "Stream"]
    var externalDeviceItems = ["raspberrypi"]
    var itemName = NSString()
    var selectedItem = NSString()
    
    var SERVER_URL: String = ""
    let USER_CHECK_URL = "aircasting_users/_design/find_record/_view/user_check?key="
    
    
    @IBOutlet weak var itemView: UITableView!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    // Sign in view
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signinView: UIView!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    // Create new user view
    
    @IBOutlet weak var createUserView: UIView!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var createUserName: UITextField!
    @IBOutlet weak var newUserPassword: UITextField!
    @IBOutlet weak var sendEmail: UITextField!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemView.delegate = self
        itemView.dataSource = self
        signinView.hidden = true
        signOutButton.hidden = true
        createUserView.hidden = true
        
        //DashboardController.bleConnectorObj.deviceNames.count
        
        
        //externalDeviceItems.append()

        // Do any additional setup after loading the view.
        
        SERVER_URL = "http://" + BackendServerConfig.serverAddress + ":" + BackendServerConfig.serverPort + "/"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        var touch : UITouch! = touches.first as! UITouch
        createUserView.hidden = true
        signinView.hidden = true
        //itemDetailsView.hidden = true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount = 0
        
        switch itemName{
            
        case "profile":
        
            if(SignedInUser.signInFlag == true)
            {
                rowCount = signedUser.count
                navigationTitle.title = "Signed In"
            }
            else
            {
                rowCount = profileItems.count
                navigationTitle.title = "Profile"
            }
           
            
        case "external":
            
            rowCount = externalDeviceItems.count
            navigationTitle.title = "External Devices"
            
        case "map":
            
            rowCount = mapItems.count
            navigationTitle.title = "Map Style"
            
        case "upload":
            
            rowCount = uploadItems.count
            navigationTitle.title = "Upload Process"
            
        default:
            println("Invalid Settings Option")
            
        }
        
        return rowCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let myCell: UITableViewCell = itemView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        switch itemName{
            
        case "profile":
            
            if(SignedInUser.signInFlag == true)
            {
                myCell.textLabel?.text = signedUser[indexPath.row]
            }
            else{
                
                myCell.textLabel?.text = profileItems[indexPath.row]
            }
            
            
        case "external":
            
            myCell.textLabel?.text = externalDeviceItems[indexPath.row]
            
        case "map":
            
            myCell.textLabel?.text = mapItems[indexPath.row]
            
            if(mapItems[indexPath.row] == MapStyle.currentSelection)
            {
                myCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
            
        case "upload":

            myCell.textLabel?.text = uploadItems[indexPath.row]
            
            if(uploadItems[indexPath.row] == UploadType.currentSelection)
            {
                myCell.accessoryType = UITableViewCellAccessoryType.Checkmark
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            }
            
        default:
            
            println("Invalid Settings Option")
            
        }
        
        return myCell
        
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        switch itemName{
            
        case "profile":
            
            var itemSelected = profileItems[indexPath.row]
            switch itemSelected{
                
                case "Sign in":
                
                    println("Sign in")
                    
                    if(SignedInUser.signInFlag == true)
                    {
                        signOutButton.hidden = false
                    }
                    else
                    {
                        signinView.hidden = false
                    }
                
                case "Create a new profile":
                
                    createUserView.hidden = false
                
                case "Forgot password":
                
                    println("Forgot password")
                
            default:
                println("Invalid Settings Option")
            }
            
        case "external":
            
            var itemSelected = externalDeviceItems[indexPath.row]
            
            DashboardController.bleConnectorObj.initializeBLE(itemSelected)
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let dashboard = storyBoard.instantiateViewControllerWithIdentifier("Dashboard") as! DashboardController
            
            dashboard.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            self.presentViewController(dashboard,  animated: true, completion: nil)
            
            
        case "map":
            
            var itemSelected = mapItems[indexPath.row]
            switch itemSelected{
                
            case "Standard":
                
                println("Standard Map")
                
            case "Satellite":
                
                println("Satellite Map")
                
            default:
                println("Invalid Settings Option")
            }
            
        case "upload":
            
            var itemSelected = uploadItems[indexPath.row]
            
            switch itemSelected{
                
            case "Record":
                
                println("Record Session")
                
            case "Stream":
                
                println("Stream Session")
                
            default:
                println("Invalid Settings Option")
            }
            
        default:
            println("Invalid Settings Option")
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //var objWrite = FileIO()
        //objFile.writeToDocumentsFile("bgValues.txt")
        
        selectedItem = NSString(string: (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)
        println(selectedItem)
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        if(itemName == "map")
        {
            MapStyle.currentSelection = selectedItem as String
            println(MapStyle.currentSelection)
            
        }
        
        if(itemName == "upload")
        {
            UploadType.currentSelection = selectedItem as String
            println(UploadType.currentSelection)

        }

    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
    

    @IBAction func backToSettings(sender: AnyObject) {
        
        var objFile = FileIO()
        
        objFile.writeToDocumentsFile("settingsValues.txt", value:"\(MapStyle.currentSelection),\(UploadType.currentSelection)")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let settingsMenu = storyBoard.instantiateViewControllerWithIdentifier("SettingsMenu") as! SettingsViewController
        
        settingsMenu.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(settingsMenu,  animated: true, completion: nil)

    }
    
    @IBAction func signIn(sender: AnyObject) {
        
        var user = userName.text
        var pass = password.text
        
        let plainData = (pass as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let encodedData = plainData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        //println("User Details: \(user),\(pass)")
        signinView.hidden = true
        //checkUser(user,password: encodedData)
        signInUser(user,password: encodedData)
    }
    
    @IBAction func signOut(sender: AnyObject) {
        
        SignedInUser.userName = "none"
        SignedInUser.userID = "none"
        SignedInUser.signInFlag = false
        signOutButton.hidden = true
        
        var objFile = FileIO()
        objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
        
        var alert = UIAlertView(title: "Success!", message: "User Signed Out", delegate: nil, cancelButtonTitle: "Okay.")
        alert.title = "Sign Out"
        
        // Move to the UI thread
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Show the alert
            alert.show()
        })

        returnToSettingsView("User Signed Out")
        
    }
    
    // Sign In User
    
    func signInUser(keyValue: String, password: String){
        
        var id:String = ""
        var username: String = ""
        var pass = ""
        
        let userCheckUrl = SERVER_URL + USER_CHECK_URL + "%22" + keyValue + "%22"
        var url: NSURL = NSURL(string: userCheckUrl)!
        var request1: NSURLRequest = NSURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
        var err: NSError?
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
        
        println(err)
        if(err == nil)
        {
            var rows: NSArray = jsonResult["rows"] as! NSArray
        
            if(rows.count == 0)
            {
                println("User Not Found")
                SignedInUser.userName = "none"
                SignedInUser.userID = "none"
                SignedInUser.signInFlag = false
                
                var objFile = FileIO()
                objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
                
                var alert = UIAlertView(title: "Failed!", message: "User Not Found", delegate: nil, cancelButtonTitle: "Okay.")
                alert.title = "Sign In"
                
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })

                returnToSettingsView("User Not Found")
            }
            else
            {
                username = rows[0].valueForKey("key") as! String
                id = rows[0].valueForKey("id") as! String
                var value: NSDictionary = rows[0].valueForKey("value") as! NSDictionary
                pass = value.valueForKey("password") as! String
                
                if(pass == password)
                {
                    println("Signed In")
                    SignedInUser.userName = username
                    SignedInUser.userID = id
                    SignedInUser.signInFlag = true
                    
                    var objFile = FileIO()
                    objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
                    
                    var alert = UIAlertView(title: "Success!", message: "User Signed In", delegate: nil, cancelButtonTitle: "Okay.")
                    alert.title = "Sign In"
                    
                    // Move to the UI thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // Show the alert
                        alert.show()
                    })

                    returnToSettingsView("Signed In")
                }
                else
                {
                    println("Invalid Password")
                    SignedInUser.userName = "none"
                    SignedInUser.userID = "none"
                    SignedInUser.signInFlag = false
                    
                    var objFile = FileIO()
                    objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
                    
                    var alert = UIAlertView(title: "Failed!", message: "Invalid Password", delegate: nil, cancelButtonTitle: "Okay.")
                    alert.title = "Sign In"
                    
                    // Move to the UI thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // Show the alert
                        alert.show()
                    })
                    
                    returnToSettingsView("Invalid Password")
                }
            }
        }
        else
        {
            println("UserCheck Error: \(err)")
            SignedInUser.userName = "none"
            SignedInUser.userID = "none"
            SignedInUser.signInFlag = false
            
            var objFile = FileIO()
            objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
            
            var alert = UIAlertView(title: "Failed!", message: "UserCheck Error", delegate: nil, cancelButtonTitle: "Okay.")
            alert.title = "Sign In"
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })

            returnToSettingsView("UserCheck Error: \(err)")
        }
    }
    
    func returnToSettingsView(msg: String)
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let settingsMenu = storyBoard.instantiateViewControllerWithIdentifier("SettingsMenu") as! SettingsViewController
        settingsMenu.itemSubtitles[0] = msg
        settingsMenu.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(settingsMenu,  animated: true, completion: nil)
    }
    
    func get(url : String, getCompleted : (succeeded: Bool, msg: String, jsonResponse: NSDictionary) -> ()) {
        //println("Inside get method")
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
    
    @IBAction func createNewUser(sender: AnyObject) {
        
        var newUserEmail = emailAddress.text
        var newUsername = createUserName.text
        var newPassword = newUserPassword.text
        var sendPermission = sendEmail.text
        var newUserUUID = "\(NSUUID().UUIDString)"
        let restRequest = RESTServices()
        var userCreated = false
        
        let plainData = (newPassword as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let encodedData = plainData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        let userCheckUrl = SERVER_URL + USER_CHECK_URL + "%22" + newUsername + "%22"
        
        var url: NSURL = NSURL(string: userCheckUrl)!
        var request1: NSURLRequest = NSURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
        var err: NSError?
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
        
        println(err)

        if(err == nil)
        {
            var rows: NSArray = jsonResult["rows"] as! NSArray
            
            if(rows.count == 0)
            {
                var dataDic = NSMutableDictionary()
                dataDic.setObject(newUserEmail, forKey: "email")
                dataDic.setObject(newUsername, forKey: "username")
                dataDic.setObject(encodedData, forKey: "encrypted_password")
                dataDic.setObject(sendPermission, forKey: "send_emails")
                dataDic.setObject(timestamp, forKey: "created_at")
                dataDic.setObject("null", forKey: "updated_at")
                dataDic.setObject("null", forKey: "reset_password_token")
                dataDic.setObject("null", forKey: "reset_password_sent_at")
                dataDic.setObject(1, forKey: "sign_in_count")
                dataDic.setObject(timestamp, forKey: "current_sign_in_at")
                dataDic.setObject("null", forKey: "last_sign_in_at")
                
                var success = restRequest.createUser(dataDic, uuid: newUserUUID)
                
                SignedInUser.userName = newUsername
                SignedInUser.userID = newUserUUID
                SignedInUser.signInFlag = true
                
                var objFile = FileIO()
                objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
                
                var alert = UIAlertView(title: "Success!", message: "New User Created and Signed In", delegate: nil, cancelButtonTitle: "Okay.")
                alert.title = "Create New User"
                
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
                
                returnToSettingsView("New User Created and Signed In")
            }
            else
            {
                println("User Already Exists")
                SignedInUser.userName = "none"
                SignedInUser.userID = "none"
                SignedInUser.signInFlag = false
                
                var objFile = FileIO()
                objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
                
                var alert = UIAlertView(title: "Failed!", message: "User Already Exists", delegate: nil, cancelButtonTitle: "Okay.")
                alert.title = "Create New User"
                
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
                
                returnToSettingsView("User Already Exists")
            }
        }
        else
        {
            println("UserCreation: \(err)")
            SignedInUser.userName = "none"
            SignedInUser.userID = "none"
            SignedInUser.signInFlag = false
            
            var objFile = FileIO()
            objFile.writeToDocumentsFile("signedInUser.txt", value:"\(SignedInUser.userName),\(SignedInUser.userID),\(SignedInUser.signInFlag)")
            
            var alert = UIAlertView(title: "Failed!", message: "User Creation Error", delegate: nil, cancelButtonTitle: "Okay.")
            alert.title = "Create New User"
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })

            
            returnToSettingsView("UserCreation Error: \(err)")
        }

    }
    
}
