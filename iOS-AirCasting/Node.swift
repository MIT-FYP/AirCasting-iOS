//
//  Node.swift
//  JavaToAstar
//
//  Created by Renji Harold on 27/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation

class Node {
    
    var neighbourList: Array<Node>
    var distanceFromStart: Float
    var lat: Double = 0
    var long: Double = 0
    var isObstacle: Bool
    var isStart: Bool
    var isGoal: Bool
    
    var parent: Node?
    var gScore: Float = 0
    var hScore: Float = 0
    var fScore: Float {
        return gScore + hScore
    }
    
    var decibel: Float = 0
    var temperature: Float = 0
    var particulateMatter: Float = 0
    var humidity: Float = 0
    
    init(){
        neighbourList = Array<Node>()
        distanceFromStart = 9999
        isObstacle = false
        isStart = false
        isGoal = false
    }
    
    init(lat: Double, long: Double){
        self.lat = lat
        self.long = long
        neighbourList = Array<Node>()
        distanceFromStart = 9999
        isObstacle = false
        isStart = false
        isGoal = false
    }
    
    init(coord: NSDictionary){
        if let lt = coord["latitude"] as? Double {
            self.lat = coord["latitude"] as! Double
        } else {
            self.lat = (coord["latitude"] as! NSString).doubleValue
        }
        if let lg = coord["longitude"] as? Double {
            self.long = coord["longitude"] as! Double
        } else {
            self.long = (coord["longitude"] as! NSString).doubleValue
        }
//        self.lat = (coord["latitude"] as! NSString).doubleValue
//        self.long = (coord["longitude"] as! NSString).doubleValue
        neighbourList = Array<Node>()
        distanceFromStart = 9999
        isObstacle = false
        isStart = false
        isGoal = false
        if let dec = coord["decibel"] as? Float {
            self.decibel = coord["decibel"] as! Float
        } else {
            self.decibel = (coord["decibel"] as! NSString).floatValue
        }
        if let tmp = coord["temperature"] as? Float {
            self.temperature = coord["temperature"] as! Float
        } else {
            self.temperature = (coord["temperature"] as! NSString).floatValue
        }
        if let pm = coord["particulate_matter"] as? Float {
            self.particulateMatter = coord["particulate_matter"] as! Float
        } else {
            self.particulateMatter = (coord["particulate_matter"] as! NSString).floatValue
        }
        if let hm = coord["humidity"] as? Float {
            self.humidity = coord["humidity"] as! Float
        } else {
            self.humidity = (coord["humidity"] as! NSString).floatValue
        }
//        self.decibel = coord["decibel"] as! Float
//        self.temperature = coord["temperature"] as! Float
//        self.particulateMatter = coord["particulate_matter"] as! Float
//        self.humidity = coord["humidity"] as! Float
    }
    
    func setParent(parent: Node, withMoveCost moveCost: Float) {
        // The G score is equal to the parent G score + the cost to move from the parent to it
        self.parent = parent
        self.gScore = parent.gScore + moveCost
    }
    
}

extension Node: Equatable {}
func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.lat == rhs.lat && lhs.long == rhs.long
}

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

extension Array {
    func indexOf<T : Equatable>(x:T) -> Int? {
        for i in 0...self.count {
            if self[i] as! T == x {
                return i
            }
        }
        return nil
    }
}
