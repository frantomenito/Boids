//
//  QuadTree.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 03.03.2023.
//

import SpriteKit

class QuadTree {
    var bounds: CGRect!
    var subdivideTreshold: Int!
    var minSubdivisionLenght: CGFloat!
    
    var nodes: [BoidNode] = []
    
    
    var topRight: QuadTree?
    var topLeft: QuadTree?
    var bottomRight: QuadTree?
    var bottomLeft: QuadTree?

    init(bounds: CGRect, subdivideTreshold: Int, minSubdivisionLenght: CGFloat) {
        self.bounds = bounds
        self.minSubdivisionLenght = minSubdivisionLenght
        self.subdivideTreshold = subdivideTreshold
        
    }
    
    func addNode(node: BoidNode) {
        guard case bounds.contains(node.position) = true else { return }
        
        if nodes.count < subdivideTreshold && minSubdivisionLenght <= min(bounds.width, bounds.height){
            nodes.append(node)
        } else {
            if topRight == nil {
                subdivide()
            }
            
            topRight!.addNode(node: node)
            bottomRight!.addNode(node: node)
            bottomLeft!.addNode(node: node)
            topLeft!.addNode(node: node)
        }
    }
    
    public func searchInSector(node: BoidNode) -> [BoidNode] {

        let searchRect = node.getSearchRect()
        

        let initialNodeGroup = search(searchRect: searchRect)

        var result = [BoidNode]()
        result.reserveCapacity(initialNodeGroup.count)
        
        for maybeNode in initialNodeGroup { //Futher searching for nodes which are located in sector of main node's perceptionCircle            
            let angle = atan2(maybeNode.position.y - node.position.y, maybeNode.position.x - node.position.x)
        
            let angleDifference = abs(-node.zRotation - angle)
            
            if angleDifference < visionAngle/2 {
                result.append(maybeNode)
            }
        }
        return result
    }
    
    func search(searchRect: CGRect) -> [BoidNode] {
        if !bounds.intersects(searchRect) { return [] }
        
        var result: [BoidNode] = []
        
        for node in nodes {
            if searchRect.contains(node.position) {
                if node.position != CGPoint(x: searchRect.midX, y: searchRect.midY) {
                    result.append(node)
                }
            }
        }
        
        if topRight != nil {
            result.append(contentsOf: topRight!.search(searchRect: searchRect))
            result.append(contentsOf: bottomRight!.search(searchRect: searchRect))
            result.append(contentsOf: bottomLeft!.search(searchRect: searchRect))
            result.append(contentsOf: topLeft!.search(searchRect: searchRect))
        }
            
        return result
    }
    
    func clear() {
        nodes = []
        
        topRight = nil
        bottomLeft = nil
        bottomRight = nil
        topLeft = nil
    }
    
    private func subdivide() {
        let topRightRect = CGRect(x: bounds.midX, y: bounds.minY, width: bounds.width/2, height: bounds.height/2)
        let bottomRightRect = CGRect(x: bounds.midX, y: bounds.midY, width: bounds.width/2, height: bounds.height/2)
        let bottomLeftRect = CGRect(x: bounds.minX, y: bounds.midY, width: bounds.width/2, height: bounds.height/2)
        let topLeftRect = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width/2, height: bounds.height/2)

        topRight = QuadTree(bounds: topRightRect, subdivideTreshold: subdivideTreshold, minSubdivisionLenght: minSubdivisionLenght)
        bottomRight = QuadTree(bounds: bottomRightRect, subdivideTreshold: subdivideTreshold, minSubdivisionLenght: minSubdivisionLenght)
        bottomLeft = QuadTree(bounds: bottomLeftRect, subdivideTreshold: subdivideTreshold, minSubdivisionLenght: minSubdivisionLenght)
        topLeft = QuadTree(bounds: topLeftRect, subdivideTreshold: subdivideTreshold, minSubdivisionLenght: minSubdivisionLenght)
    }
}
