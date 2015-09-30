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
  
    
    @IBOutlet weak var orangeSlider: UISlider!
    @IBOutlet weak var yellowSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    
    // Legend bar text fields
    
    @IBOutlet weak var mainThreshold1: UILabel!
    @IBOutlet weak var mainThreshold2: UILabel!
    @IBOutlet weak var mainThreshold3: UILabel!
    @IBOutlet weak var mainThreshold4: UILabel!
    @IBOutlet weak var mainThreshold5: UILabel!
    @IBOutlet weak var mainThreshold6: UILabel!
    @IBOutlet weak var mainThreshold7: UILabel!
    @IBOutlet weak var mainThreshold8: UILabel!
    @IBOutlet weak var mainThreshold9: UILabel!
    @IBOutlet weak var mainThreshold10: UILabel!
    
    
    
    
    
    
    // Variables for background
    var redLegendView = UIImageView(image: UIImage(named: "redLegend"))
    var orangeLegendView = UIImageView(image: UIImage(named: "orangeLegend"))
    var yellowLegendView = UIImageView(image: UIImage(named: "yellowLegend"))
    var greenLegendView = UIImageView(image: UIImage(named: "greenLegend"))
    
    var startCordX: CGFloat = 0
    var startCordY: CGFloat = 52

    
    //Object for Calculating Height
    var objBgHeight = BackgroundCustomization()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLegendMenu.hidden = true
        
        redTextField.delegate = self
        orangeTextField.delegate = self
        yellowTextField.delegate = self
        greenTextField.delegate = self

        //Populate saved values from file
        updateBackground()
        
        //Initiate timer to display clocks
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: ("updateClocks"), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func saveChangesButton(sender: UIButton) {

        //Calculate the heights of background row based on threshold values set in menu
        let bgHeights = objBgHeight.calculateHeights(redTextField.text.toInt()!, orange: orangeTextField.text.toInt()!, yellow: yellowTextField.text.toInt()!, green: greenTextField.text.toInt()!, black: blackTextField.text.toInt()!)
        
        println("ht: \(bgHeights.redHt)")
        println("ht: \(bgHeights.orangeHt)")
        println("ht: \(bgHeights.yellowHt)")
        println("ht: \(bgHeights.greenHt)")
        
        //Draw background
        setBackground(bgHeights.redHt, orangeHt: bgHeights.orangeHt, yellowHt: bgHeights.yellowHt, greenHt: bgHeights.greenHt)
        
        //Hide menu
        updateLegendMenu.hidden = true
        
    }
    
    @IBAction func restoreDefaultButton(sender: UIButton) {
        updateLegendMenu.hidden = true
        
        //Set default values
        restoreDefault()
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
        //Draw again when orientation changes
        updateBackground()
        
    }
    
    //Update textfield when slider value changes
    @IBAction func updateTextFields(sender: UISlider) {
       
//        println("2: \(sender.tag)")
        
        switch sender.tag {
        case 1: orangeTextField.text = "\(Int(orangeSlider.value))"
        case 2: yellowTextField.text = "\(Int(yellowSlider.value))"
        case 3: greenTextField.text = "\(Int(greenSlider.value))"
        default: println("Invalid Slider error - GraphView")
        }
        
    }

    //Update slider when textfield changes and update thresholds
    @IBAction func endTxtUpdate(sender: UITextField) {
//        println("txt1: \(sender.text)")
        updateThresholds()
    }
    
    //Update threshold when slider value changes
    @IBAction func endSliderUpdate(sender: UISlider) {
//        println("slider1: \(sender.value)")
        updateThresholds()
    }
    
    //Update threshold values based on changes
    func updateThresholds(){
        
        println("redTextField.text: \(redTextField.text)")
        println("orangeTextField: \(orangeTextField.text)")
        println("yellowTextField: \(yellowTextField.text)")
        println("greenTextField: \(greenTextField.text)")
        println("blackTextField: \(blackTextField.text)")
        
        if redTextField.text.toInt() < orangeTextField.text.toInt() {
            orangeTextField.text = String(redTextField.text.toInt()! - 1)
        }
        if orangeTextField.text.toInt() < yellowTextField.text.toInt() {
            yellowTextField.text = String(orangeTextField.text.toInt()! - 1)
        }
        if yellowTextField.text.toInt() < greenTextField.text.toInt() {
            greenTextField.text = String(yellowTextField.text.toInt()! - 1)
        }
        if greenTextField.text.toInt() < blackTextField.text.toInt() {
            blackTextField.text = String(greenTextField.text.toInt()! - 1)
        }
        
        //Set minimums and maximums for sliders
        setSliderMinMax((redTextField.text as NSString).floatValue,
            minimum: (blackTextField.text as NSString).floatValue)
        
        orangeSlider.value = (orangeTextField.text as NSString).floatValue
        yellowSlider.value = (yellowTextField.text as NSString).floatValue
        greenSlider.value = (greenTextField.text as NSString).floatValue
        
        updateThresholdLabels()
        
    }
    
    // Clocks
    func updateClocks()
        
    {
        startClock.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle:NSDateFormatterStyle.NoStyle , timeStyle: NSDateFormatterStyle.MediumStyle)
        
        finishClock.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle:NSDateFormatterStyle.NoStyle , timeStyle: NSDateFormatterStyle.MediumStyle)
    }
    
    
    //Retrieve saved values from file
    func updateBackground(){
        var objRead = FileIO()
        
        var htValues = objRead.readFromDocumentsFile("bgValues.txt")
        
        if htValues.lowercaseString.rangeOfString("error") != nil {
            
            restoreDefault()
            
        } else{
            
            var arrHt = split(htValues) {$0 == ","}
            
            if arrHt.count == 9 {
                
//                println("array size = 9")
                
                var redHt = NSString(string: arrHt[0])
                var orangeHt = NSString(string: arrHt[1])
                var yellowHt = NSString(string: arrHt[2])
                var greenHt = NSString(string: arrHt[3])
                var redTxt = NSString(string: arrHt[4])
                var orangeTxt = NSString(string: arrHt[5])
                var yellowTxt = NSString(string: arrHt[6])
                var greenTxt = NSString(string: arrHt[7])
                var blackTxt = NSString(string: arrHt[8])
                
                redTextField.text = redTxt as String
                orangeTextField.text = orangeTxt as String
                yellowTextField.text = yellowTxt as String
                greenTextField.text = greenTxt as String
                blackTextField.text = blackTxt as String
                
                orangeSlider.value = orangeTxt.floatValue
                yellowSlider.value = yellowTxt.floatValue
                greenSlider.value = greenTxt.floatValue
                
                //Set minimums and maximums for sliders
                setSliderMinMax((redTextField.text as NSString).floatValue,
                    minimum: (blackTextField.text as NSString).floatValue)
                
                updateThresholdLabels()
                
                setBackground(redHt.doubleValue, orangeHt: orangeHt.doubleValue, yellowHt: yellowHt.doubleValue, greenHt: greenHt.doubleValue)
            } else{
                println("GraphView:updatBackground - bgValues.txt File corrupt")
            }

//            println("RH: \(redHt)")
//            println("OH: \(orangeHt)")
//            println("YH: \(yellowHt)")
//            println("GH: \(greenHt)")
        }
    }
    
    func restoreDefault(){
        
        var redHt = 0.25
        var orangeHt = 0.125
        var yellowHt = 0.125
        var greenHt = 0.5
        var redTxt = 100
        var orangeTxt = 80
        var yellowTxt = 70
        var greenTxt = 60
        var blackTxt = 20
        
        redTextField.text = "\(redTxt)"
        orangeTextField.text = "\(orangeTxt)"
        yellowTextField.text = "\(yellowTxt)"
        greenTextField.text = "\(greenTxt)"
        blackTextField.text = "\(blackTxt)"
        
        orangeSlider.value = Float(orangeTxt)
        yellowSlider.value = Float(yellowTxt)
        greenSlider.value = Float(greenTxt)
        
        //Set minimums and maximums for sliders
        setSliderMinMax((redTextField.text as NSString).floatValue,
            minimum: (blackTextField.text as NSString).floatValue)
        
        updateThresholdLabels()
        
        var storeHt = BackgroundCustomization()
        storeHt.storeSetting(redHt, orangeHt: orangeHt, yellowHt: yellowHt, greenHt: greenHt, redTxt: redTxt, orangeTxt: orangeTxt, yellowTxt: yellowTxt, greenTxt: greenTxt, blackTxt: blackTxt)
    
        setBackground(redHt, orangeHt: orangeHt, yellowHt: yellowHt, greenHt: greenHt)
    }
    
    //Set minimums and maximums for sliders
    func setSliderMinMax(maximum: Float, minimum: Float){
        
//        println("maximum: \(maximum) minimum: \(minimum)")
        orangeSlider.maximumValue = maximum
        orangeSlider.minimumValue = minimum
        
        yellowSlider.maximumValue = maximum
        yellowSlider.minimumValue = minimum
        
        greenSlider.maximumValue = maximum
        greenSlider.minimumValue = minimum
        
    }
    
    //Draws the background
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
    
    func updateThresholdLabels(){
        
        mainThreshold1.text = blackTextField.text
        mainThreshold2.text = greenTextField.text
        mainThreshold3.text = yellowTextField.text
        mainThreshold4.text = orangeTextField.text
        mainThreshold5.text = redTextField.text
        
        mainThreshold6.text = blackTextField.text
        mainThreshold7.text = greenTextField.text
        mainThreshold8.text = yellowTextField.text
        mainThreshold9.text = orangeTextField.text
        mainThreshold10.text = redTextField.text
        
        
    }
    
}
