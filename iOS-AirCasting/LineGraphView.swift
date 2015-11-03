//
//  LineGraphView.swift
//  iOS-AirCasting
//
//  Created by Akmal Hossain on 17/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation
import UIKit

class LineGraphView: UIView {
    
    var start:CGPoint!
    var end:CGPoint!
    
    init(start:CGPoint, end:CGPoint, frame:CGRect){
        super.init(frame: frame)
        self.start = start
        self.end = end
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        
        let plusPath = UIBezierPath()
        plusPath.lineWidth = 2.0
        plusPath.moveToPoint(start)
        plusPath.addLineToPoint(end)
        UIColor.whiteColor().setStroke()
        plusPath.stroke()
    }
    
    
    
}


