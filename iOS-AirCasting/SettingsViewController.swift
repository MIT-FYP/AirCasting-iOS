//
//  SettingsViewController.swift
//  iOS-AirCasting
//
//  Created by Akmal Hossain on 4/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit



class SettingsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
    
    var settingsMenuItems = ["Profile","External devices","Map style","Upload process","Backend settings"]
    var itemSubtitles = ["Create an account or sign in", "Select sensor device", "Select map view type", "Select data upload type", "Set backend address and port"]

    @IBOutlet weak var settingsMenuView: UITableView!
    
    // Backend Settings view
    
    @IBOutlet weak var backendSettingsView: UIView!
    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var serverPort: UITextField!
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settingsMenuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let myCell: UITableViewCell = settingsMenuView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        myCell.textLabel?.text = settingsMenuItems[indexPath.row]
        myCell.detailTextLabel?.text = itemSubtitles[indexPath.row]

        return myCell
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        var itemSelected = settingsMenuItems[indexPath.row]
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let itemView = storyBoard.instantiateViewControllerWithIdentifier("ItemView") as! SettingsItemViewController
        itemView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        switch itemSelected{
            
            case "Profile":
            
                println("Create an account or sign in")
                itemView.itemName = NSString(string: "profile")
            
                self.presentViewController(itemView,  animated: true, completion: nil)
            
            case "External devices":
            
                println("Select sensor device")
                itemView.itemName = NSString(string: "external")
            
                self.presentViewController(itemView,  animated: true, completion: nil)
            
            case "Map style":
            
                println("Select map view type")
                itemView.itemName = NSString(string: "map")

                self.presentViewController(itemView,  animated: true, completion: nil)
            
            case "Upload process":
            
                println("Select data upload type")
                itemView.itemName = NSString(string: "upload")
                
                self.presentViewController(itemView,  animated: true, completion: nil)
            
            case "Backend settings":
            
                println("Set backend address and port")
                backendSettingsView.hidden = false
                serverAddress.text = BackendServerConfig.serverAddress
                serverPort.text = BackendServerConfig.serverPort
        
        default:
            println("Invalid Settings Option")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settingsMenuView.delegate = self
        settingsMenuView.dataSource = self
        backendSettingsView.hidden = true
        
        if(SignedInUser.signInFlag == true)
        {
            itemSubtitles[0] = "Signed In"
        }
        
        var objRead = FileIO()
        
        var itemValues = objRead.readFromDocumentsFile("settingsValues.txt")
        
        if itemValues.lowercaseString.rangeOfString("error") != nil
        {
            println("No Initial data")
        }
        else
        {
            var selectedItems = split(itemValues) {$0 == ","}
            println(selectedItems)
            MapStyle.currentSelection = selectedItems[0]
            UploadType.currentSelection = selectedItems[1]
        }
        
        var serverSettings = objRead.readFromDocumentsFile("backendServerSettings.txt")
        
        if serverSettings.lowercaseString.rangeOfString("error") != nil
        {
            println("No Initial server settings")
        }
        else
        {
            var currentSettings = split(serverSettings) {$0 == ","}
            println(currentSettings)
            BackendServerConfig.serverAddress = currentSettings[0]
            BackendServerConfig.serverPort = currentSettings[1]
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backDashboardView(sender: AnyObject) {
    
        var objFile = FileIO()
        
        objFile.writeToDocumentsFile("settingsValues.txt", value:"\(MapStyle.currentSelection),\(UploadType.currentSelection)")
        objFile.writeToDocumentsFile("backendServerSettings.txt", value:"\(BackendServerConfig.serverAddress),\(BackendServerConfig.serverPort)")

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let dashboard = storyBoard.instantiateViewControllerWithIdentifier("Dashboard") as! DashboardController
        
        dashboard.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(dashboard,  animated: true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    
        var touch : UITouch! = touches.first as! UITouch
        backendSettingsView.hidden = true
        //itemDetailsView.hidden = true
    }
    
    @IBAction func setBackendServer(sender: AnyObject) {
        
        var address = serverAddress.text
        var port = serverPort.text
        
        println("Server Address: \(address)")
        println("Port Number: \(port)")
        backendSettingsView.hidden = true
        
        BackendServerConfig.serverAddress = address
        BackendServerConfig.serverPort = port
        
        var objFile = FileIO()
        
        objFile.writeToDocumentsFile("backendServerSettings.txt", value:"\(BackendServerConfig.serverAddress),\(BackendServerConfig.serverPort)")
        
        
    }

}
