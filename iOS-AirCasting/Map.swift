//
//  Map.swift
//  JavaToAstar
//
//  Created by Renji Harold on 27/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation
import CoreLocation


class Map{
    
    var mapList : Array<Node> = Array<Node>()
    var startLocationLat: Double = 0
    var startLocationLong: Double = 0
    var goalLocationLat: Double = 0
    var goalLocationLong: Double = 0
    
    //*******************************
    
    //Initialize the map for A*
    func initializeMap(source: String, destination: String) {
        
        //Get coordinates of addresses entered by user
        var sourceCoordinates = getCoordinates(source)
        var destinationCoordinates = getCoordinates(destination)
        
        startLocationLat = Double(sourceCoordinates["latitude"]!)
        startLocationLong = Double(sourceCoordinates["longitude"]!)
        goalLocationLat = Double(destinationCoordinates["latitude"]!)
        goalLocationLong = Double(destinationCoordinates["longitude"]!)
        
        println(sourceCoordinates)
        println(destinationCoordinates)
        
        //Find the midpoint between both points
        var midpointp = getMidPointPlanar(Float(sourceCoordinates["latitude"]!), long1: Float(sourceCoordinates["longitude"]!), lat2: Float(destinationCoordinates["latitude"]!), long2: Float(destinationCoordinates["longitude"]!))
        var mpLat: Double = midpointp.objectForKey("lat") as! Double
        var mpLong: Double = midpointp.objectForKey("long") as! Double
        
        println("midpointPlanar: \(mpLat),\(mpLong)")
        
        //Find the distance between source and midpoint as use that as radius for the circle
        var radius = getDistance(sourceCoordinates["latitude"]!, sourceLong: sourceCoordinates["longitude"]!, destLat: mpLat, destLong: mpLong)
        radius = radius / 100
        
        println("radius: \(radius)")
        
        //Retrieve all coordinates that fall within the circle
        var coordinateList = getFilteredCoordinates(radius, mpLat: mpLat, mpLong: mpLong)
        
        println(coordinateList.count)
        
        var mapList = Array<Node>()
        
        mapList = convertJsonToNode(coordinateList)
        
        self.mapList = mapList
        
    }
    
    //Get array of nodes
    func convertJsonToNode(coordinateList: NSMutableArray) -> Array<Node> {
        
        var mapList = Array<Node>()
        var sortedList = getMapList(coordinateList)
        
        println("slistCnt: \(sortedList.count)")
        
        for i in 0..<sortedList.count {
            mapList.append(sortedList[i])
        }
        
        return mapList
        
    }
    
    func getMapList(coordinateList: NSMutableArray) -> Array<Node> {
        
        //        var arrNeighbour: [Double: Node] = [Double: Node]()
        var arrNode: Array<SortedNbr> = Array<SortedNbr>()
        
        //        var coord: NSDictionary = coordinateList[0] as! NSDictionary
        //        var coordLat: NSString = coord["latitude"] as! NSString
        //        var coordLong: NSString = coord["longitude"] as! NSString
        
        println(coordinateList.count)
        
        for point in coordinateList {
            
            //            if !(startLocationLat == (point["latitude"] as! NSString).floatValue &&
            //                startLocationLong == (point["longitude"] as! NSString).floatValue) {
            var distance = getDistance(Double(startLocationLat), sourceLong: Double(startLocationLong),
                destLat: (point["latitude"] as! NSString).doubleValue,
                destLong: (point["longitude"] as! NSString).doubleValue)
            
            //                arrNeighbour[distance] = createNode(point as! NSDictionary)
            arrNode.append(SortedNbr(distance: distance, node: createNode(point as! NSDictionary)))
            //            }
            
        }
        
        println(arrNode.count)
        var neighbourList = Array<Node>()
        
        arrNode.sort({ $0.distance <= $1.distance })

        for i in 0..<arrNode.count {
            neighbourList.append(arrNode[i].node)
        }
        
        //        println(neighbourList)
        
        return neighbourList
        
    }
    
    func getNode(lat: Double, long: Double) -> Node {
        
        var node: Node = Node()
        
        for nd in mapList {
            
            if nd.lat == lat && nd.long == long {
                node = nd
                break
            }
        }
        
        return node
    }
    
    //Get list of neighbours for a particular node
    func getNeighbourList(currentNode: Node, nodeList: Array<Node>) -> Array<Node> {

        var arrNode: Array<SortedNbr> = Array<SortedNbr>()
        
        
        var coordLat: Double = currentNode.lat
        var coordLong: Double = currentNode.long
        
        for node in nodeList {
            
            if !(coordLat == node.lat && coordLong == node.long) {
                var distance = getDistance(coordLat, sourceLong: coordLong,
                    destLat: node.lat,
                    destLong: node.long)

                arrNode.append(SortedNbr(distance: distance, node: node))
                
            }
            
        }
        var neighbourList = Array<Node>()
        
        arrNode.sort({ $0.distance <= $1.distance })
        
        for i in 0..<arrNode.count {
            if !(neighbourList.contains(arrNode[i].node)) {
                neighbourList.append(arrNode[i].node)
                println("dist:\(arrNode[i].distance); lat: \(arrNode[i].node.lat), \(arrNode[i].node.long)")
            }
            if neighbourList.count == 8 {
                break
            }
            
        }
        
        return neighbourList
        
    }
    
    func createNode(coordinate: NSDictionary) -> Node {
        
        return Node(coord: coordinate)
    }
    
    //Get all coordinates that fall within the circle
    func getFilteredCoordinates(radius: Double, mpLat: Double, mpLong: Double) -> NSMutableArray {
        
        let couchURL: String = "http://115.146.85.75:5984/aircasting_database/_design/find_record/_list/filter_latlong/find_latlong?radius="
        let urlPath: String = couchURL  + String(stringInterpolationSegment: radius) + "&centreLat="+String(stringInterpolationSegment: mpLat)+"&centreLong=" + String(stringInterpolationSegment: mpLong)
        println(urlPath)
        
        var url: NSURL = NSURL(string: urlPath)!
        var request1: NSURLRequest = NSURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
        var dataVal: NSData =  NSURLConnection.sendSynchronousRequest(request1, returningResponse: response, error:nil)!
        var err: NSError?
        //        println("\(response)")
        var jsonResult: NSMutableArray = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSMutableArray
        
        return jsonResult
    }
    
    //Get the latitude and longitude of an address
    func getCoordinates(address: String) -> Dictionary<String,Double>{
        
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        var coodinates:[String:Double] = ["latitude":0.0,"longitude":0.0]
        
        var esc_addr: String = address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var req: String = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=\(esc_addr)"
        
        var result = String(contentsOfURL: NSURL(string: req)!, encoding: NSUTF8StringEncoding, error: nil)
        
        if((result) != nil)
        {
            var scanner: NSScanner = NSScanner(string: result!)
            
            if scanner.scanUpToString("\"lat\" :", intoString: nil) && scanner.scanString("\"lat\" :", intoString: nil) {
                
                scanner.scanDouble(&latitude)
                coodinates["latitude"] = latitude
                
                if scanner.scanUpToString("\"lng\" :", intoString: nil) && scanner.scanString("\"lng\" :", intoString: nil) {
                    
                    scanner.scanDouble(&longitude)
                    coodinates["longitude"] = longitude
                    
                }
                
            }
            
        }
        return coodinates
    }
    
    //Find the midpoint between two coordinates
    func getMidPointPlanar(lat1: Float, long1: Float, lat2: Float, long2: Float) -> NSMutableDictionary {
        
        var midpointLat: Double = Double(lat1 + lat2)/2
        var midpointLong: Double = Double(long1 + long2)/2
        
        var midpoint: NSMutableDictionary = NSMutableDictionary()
        midpoint.setObject(midpointLat, forKey: "lat")
        midpoint.setObject(midpointLong, forKey: "long")
        return midpoint
        
    }
    
    //Find the distance between two points
    func getDistance(sourceLat: Double, sourceLong: Double, destLat: Double, destLong: Double) -> Double{
        
        var source = CLLocation(latitude: sourceLat, longitude: sourceLong)
        var destination = CLLocation(latitude: destLat, longitude: destLong)
        
        var distanceMeters = source.distanceFromLocation(destination)
        var distanceKM = distanceMeters / 1000
        let roundedTwoDigit = distanceKM.roundedTwoDigit
        return roundedTwoDigit
        
    }
    
    func calculateDistance(source: Node,destination: Node) -> Double{
        
        var source = CLLocation(latitude: Double(source.lat), longitude: Double(source.long))
        var destination = CLLocation(latitude: Double(destination.lat), longitude: Double(destination.long))
        
        var distanceMeters = source.distanceFromLocation(destination)
        var distanceKM = distanceMeters / 1000
        let roundedTwoDigit = distanceKM.roundedTwoDigit
        return roundedTwoDigit
    }
    
    
}

private class SortedNbr {
    
    var distance: Double
    var node: Node
    
    init(distance: Double, node: Node){
        self.distance = distance
        self.node = node
    }
}


extension Double{
    
    var roundedTwoDigit:Double{
        
        return Double(round(100*self)/100)
        
    }
}
