//
//  BackgroundCustomization.swift
//  AirC
//
//  Created by Renji Harold on 24/08/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation

class BackgroundCustomization {
    
    func calculateHeights(red: Int, orange: Int, yellow: Int, green: Int, black: Int) -> (redHt: Double, orangeHt: Double, yellowHt: Double, greenHt: Double){
        
        var redHeight: Double = 0
        var orangeHeight: Double = 0
        var yellowHeight: Double = 0
        var greenHeight: Double = 0
        
        var totalHeight = red - black
        
        var blackGreenDiff = green - black
        var greenYellowDiff = yellow - green
        var yellowOrangeDiff = orange - yellow
        var orangeRedDiff = red - orange
        
        greenHeight = Double(blackGreenDiff)/Double(totalHeight)
        yellowHeight = Double(greenYellowDiff)/Double(totalHeight)
        orangeHeight = Double(yellowOrangeDiff)/Double(totalHeight)
        redHeight = Double(orangeRedDiff)/Double(totalHeight)
        
//        var heights: [Int] = [greenHeight, yellowHeight, orangeHeight, redHeight]
        
        println("RH: \(redHeight)")
        println("OH: \(orangeHeight)")
        println("YH: \(yellowHeight)")
        println("GH: \(greenHeight)")
        
        // Store value to file
        storeSetting(redHeight, orangeHt: orangeHeight, yellowHt: yellowHeight, greenHt: greenHeight, redTxt: red, orangeTxt: orange, yellowTxt: yellow, greenTxt: green, blackTxt: black)
//        return (Int(redHeight), Int(orangeHeight), Int(yellowHeight), Int(greenHeight))
        return (redHeight, orangeHeight, yellowHeight, greenHeight)
    }
    
    func storeSetting(redHt: Double, orangeHt: Double, yellowHt: Double, greenHt: Double, redTxt: Int, orangeTxt: Int, yellowTxt: Int, greenTxt: Int, blackTxt: Int){
        var objFile = FileIO()
        
        objFile.writeToDocumentsFile("bgValues.txt", value: "\(redHt),\(orangeHt),\(yellowHt),\(greenHt),\(redTxt),\(orangeTxt),\(yellowTxt),\(greenTxt),\(blackTxt)")
    }

}