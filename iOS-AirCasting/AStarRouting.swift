//
//  AStarRouting.swift
//  JavaToAstar
//
//  Created by Renji Harold on 4/11/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation

class AStarRouting {
    
    var map: Map
    
    init(iMap: Map) {
        map = iMap
    }
    
    func calculateShortestPath(startLat: Double, startLong: Double, goalLat: Double, goalLong: Double, pollution: String) -> [Node]? {
        
        println("calculating..")
        var goalNode = map.getNode(goalLat, long: goalLong)
        //initialising open and closed list
        var closedList = Array<Node>()
        var openList = [map.getNode(startLat, long: startLong)]
 
        
        while !openList.isEmpty {
            //            println("Openlist not empty")
            
            let currentNode = openList.removeAtIndex(0)
            //            println("currentNode-lat:\(currentNode.lat), long:\(currentNode.long)")
            
            if currentNode.lat == goalLat && currentNode.long == goalLong {
                println("Path found")
                return reconstructPath(currentNode)
            }
            
            closedList.append(currentNode)
            
            //Get the neighbours of the current position and find the next best node
            
            var neighbourList = map.getNeighbourList(currentNode, nodeList: map.mapList)
            
            for neighbour in neighbourList {
                
                //If we have already traversed this node ignore and continue
                if closedList.contains(neighbour) {
                    println("in closed list - ignore")
                    continue
                }
                
                
                var costToNeighbour: Float = neighbour.decibel
                
                if pollution == "decibel" {
                    costToNeighbour = neighbour.decibel
                } else if pollution == "humidity" {
                    costToNeighbour = neighbour.humidity
                } else if pollution == "temperature" {
                    costToNeighbour = neighbour.temperature
                } else if pollution == "particulate matter" {
                    costToNeighbour = neighbour.particulateMatter
                } else {
                    costToNeighbour = neighbour.decibel
                }
//                let costToNeighbour = neighbour.decibel
//                let costToNeighbour = Float(map.calculateDistance(currentNode, destination: neighbour))
                println("costToNeighbour:\(costToNeighbour)")
                
                // Check if the step is already in the open list
                if let existingIndex = find(openList, neighbour) {
                    
                    // retrieve the old one (which has its scores already computed)
                    let step = openList[existingIndex]
                    println("currentNode.gScore: \(currentNode.gScore); step.gScore: \(step.gScore)")
                    
                    // check to see if the G score for that step is lower if we use the current step to get there
                    if currentNode.gScore + costToNeighbour < step.gScore {
                        println("gscore lower than step")
                        // replace the step's existing parent with the current step
                        step.setParent(currentNode, withMoveCost: costToNeighbour)
                        
                        // Because the G score has changed, the F score may have changed too
                        // So to keep the open list ordered we have to remove the step, and re-insert it with
                        // the insert function which is preserving the list ordered by F score
                        openList.removeAtIndex(existingIndex)
                        insertNode(step, inOpenList: &openList)
                    }
                } else {
                    println("not in open list")
                    //set current node as parent
                    neighbour.setParent(currentNode, withMoveCost: costToNeighbour)
                    
                    // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                    neighbour.hScore = hScoreFromGoal(neighbour, toCoord: goalNode)
                    
                    // Add it with the function which preserves the list ordered by F score
                    insertNode(neighbour, inOpenList: &openList)
                    
                }
                
                //                }
                
            }
            
        }
        println("no path found")
        //No path found
        return nil
    }
    
    private func reconstructPath(lastNode: Node) -> [Node] {
        var shortestPath = [Node]()
        var currentNode = lastNode
        while let parent = currentNode.parent { // if parent is nil, then it is our starting step, so don't include it
            shortestPath.insert(currentNode, atIndex: 0)
            currentNode = parent
        }
        return shortestPath
    }
    
    // Insert a node in the open list
    // The open list is ordered from lowest to highest fScore
    private func insertNode(node: Node, inout inOpenList openList: [Node]) {
        openList.append(node)
        openList.sort { $0.fScore <= $1.fScore }
    }
    
    // Compute the H score from a position to another (from the current position to the final desired position)
    func hScoreFromGoal(fromCoord: Node, toCoord: Node) -> Float {
        // Here we use the Manhattan method, which calculates the total number of steps moved horizontally and vertically to reach the final desired step from the current step, ignoring any obstacles that may be in teh way
        return Float(abs(toCoord.lat - fromCoord.lat) + abs(toCoord.long - fromCoord.long))
    }
    
    
    
}
