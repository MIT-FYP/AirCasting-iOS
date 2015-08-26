//
//  GraphViewController.swift
//  AirC
//
//  Created by Renji Harold on 5/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var legendBarLabel: UIImageView!
    @IBOutlet weak var updateLegendMenu: UIView!
    
    //Clocks
    
    @IBOutlet weak var startClock: UILabel!
    @IBOutlet weak var finishClock: UILabel!
    
    
    // Text Fields
    
   
    @IBOutlet weak var redTextField: UITextField!
    @IBOutlet weak var orangeTextField: UITextField!
    @IBOutlet weak var yellowTextField: UITextField!
    @IBOutlet weak var greenTextField: UITextField!
    @IBOutlet weak var blackTextField: UITextField!
  
    
    // Variables for background
    
    var redLegendView = UIImageView(image: UIImage(named: "redLegend"))
    var orangeLegendView = UIImageView(image: UIImage(named: "orangeLegend"))
    var yellowLegendView = UIImageView(image: UIImage(named: "yellowLegend"))
    var greenLegendView = UIImageView(image: UIImage(named: "greenLegend"))
    
    var startCordX: CGFloat = 0
    var startCordY: CGFloat = 70
    
    //    var redLegendWidth: Int = 0
    //    var redLegendHeight: Int = 0
    //
    //    var orangeLegendWidth: Int = 0
    //    var orangeLegendHeight: Int = 0
    //
    //    var yellowLegendWidth: Int = 0
    //    var yellowLegendHeight: Int = 0
    //
    //    var greenLegendWidth: Int = 0
    //    var greenLegendHeight: Int = 0
    //
    var legendWidth = 0
    var legendHeight = 0
    
    
    // Finshed
    
    //Object for Calculating Height
    var objBgHeight = BackgroundCustomization()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLegendMenu.hidden = true
        
        redTextField.delegate = self
        orangeTextField.delegate = self
        yellowTextField.delegate = self
        greenTextField.delegate = self
        
        //        defaultBackground()
        updateBackground()
        
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: ("updateClocks"), userInfo: nil, repeats: true)
        
    }
    @IBAction func saveChangesButton(sender: UIButton) {
        
        
        
        //        var bgHeights: [Int] = []
        let bgHeights = objBgHeight.calculateHeights(redTextField.text.toInt()!, orange: orangeTextField.text.toInt()!, yellow: yellowTextField.text.toInt()!, green: greenTextField.text.toInt()!, black: blackTextField.text.toInt()!)
        
        println("ht: \(bgHeights.redHt)")
        println("ht: \(bgHeights.orangeHt)")
        println("ht: \(bgHeights.yellowHt)")
        println("ht: \(bgHeights.greenHt)")
        
        setBackground(bgHeights.redHt, orangeHt: bgHeights.orangeHt, yellowHt: bgHeights.yellowHt, greenHt: bgHeights.greenHt)
        updateLegendMenu.hidden = true
        //        updateBackground()
        
    }
    
    @IBAction func restoreDefaultButton(sender: UIButton) {
        updateLegendMenu.hidden = true
        restoreDefault()
        //        defaultBackground()
    }
    
    @IBAction func displayLegendMenu(sender: UITapGestureRecognizer) {
        updateLegendMenu.hidden = false
    }
    
    @IBAction func toDashboard(sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let dashboard = storyBoard.instantiateViewControllerWithIdentifier("Dashboard") as! DashboardController
        
        dashboard.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController(dashboard,  animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        
        updateBackground()
        
    }
    
    // Clocks
    
    func updateClocks()
        
    {
        startClock.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle:NSDateFormatterStyle.NoStyle , timeStyle: NSDateFormatterStyle.MediumStyle)
        
        finishClock.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle:NSDateFormatterStyle.NoStyle , timeStyle: NSDateFormatterStyle.MediumStyle)
    }
    
    
    func setBackground(redHt: Double, orangeHt: Double, yellowHt: Double, greenHt: Double){
        
        var legendWidth = view.frame.size.width
        var legendHeight = view.bounds.size.height - 100
        
        var redLegendWidth = legendWidth
        var redLegendHeight = (view.bounds.size.height-100) * CGFloat(redHt)
        
        var orangeLegendWidth = legendWidth
        var orangeLegendHeight = (view.bounds.size.height-100) * CGFloat(orangeHt)
        
        var yellowLegendWidth = legendWidth
        var yellowLegendHeight = (view.bounds.size.height-100) * CGFloat(yellowHt)
        
        var greenLegendWidth = legendWidth
        var greenLegendHeight = (view.bounds.size.height-100) * CGFloat(greenHt)
        
        
        var redYAxis = startCordY
        var orangeYAxis = redYAxis + redLegendHeight
        var yellowYAxis = orangeYAxis + orangeLegendHeight
        var greenYAxis = yellowYAxis + yellowLegendHeight
        
        redLegendView.frame = CGRect(x: startCordX, y: redYAxis, width: redLegendWidth, height: redLegendHeight)
        view.addSubview(redLegendView)
        view.sendSubviewToBack(redLegendView)
        
        orangeLegendView.frame = CGRect(x: startCordX, y: orangeYAxis, width: orangeLegendWidth, height: orangeLegendHeight)
        view.addSubview(orangeLegendView)
        view.sendSubviewToBack(orangeLegendView)
        
        yellowLegendView.frame = CGRect(x: startCordX, y: yellowYAxis, width: yellowLegendWidth, height: yellowLegendHeight)
        view.addSubview(yellowLegendView)
        view.sendSubviewToBack(yellowLegendView)
        
        greenLegendView.frame = CGRect(x: startCordX, y: greenYAxis, width: greenLegendWidth, height: greenLegendHeight)
        view.addSubview(greenLegendView)
        view.sendSubviewToBack(greenLegendView)
    }
    
    func updateBackground(){
        var objRead = FileIO()
        
        var htValues = objRead.readFromDocumentsFile("bgValues.txt")
        
        if htValues.lowercaseString.rangeOfString("error") != nil {
            
            restoreDefault()
            
        } else{
            
            var arrHt = split(htValues) {$0 == ","}
            var redHt = NSString(string: arrHt[0])
            var orangeHt = NSString(string: arrHt[1])
            var yellowHt = NSString(string: arrHt[2])
            var greenHt = NSString(string: arrHt[3])
            
            
            setBackground(redHt.doubleValue, orangeHt: orangeHt.doubleValue, yellowHt: yellowHt.doubleValue, greenHt: greenHt.doubleValue)
            
            println("RH: \(redHt)")
            println("OH: \(orangeHt)")
            println("YH: \(yellowHt)")
            println("GH: \(greenHt)")
        }
    }
    
    func restoreDefault(){
        
        
        var redHt = 0.25
        var orangeHt = 0.125
        var yellowHt = 0.125
        var greenHt = 0.5
        
        setBackground(redHt, orangeHt: orangeHt, yellowHt: yellowHt, greenHt: greenHt)
    }
    
}
