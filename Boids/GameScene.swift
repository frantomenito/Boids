//
//  GameScene.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 16.02.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    //Global variables
    var borderFrame: CGRect = .zero
    var nodeArray: [BoidNode] = []
    var updateCount: Int = 0
    
    var previousNodeTree: QuadTree!
    var currentNodeTree: QuadTree!
    
    let nodeTexture = SKTexture(image: UIImage(named: "triangle")!) //Using the same texture to reduce amount of draws. See https://developer.apple.com/documentation/spritekit/nodes_for_scene_building/maximizing_node_drawing_performance

    
    //MARK: - DidMove
    override func didMove(to view: SKView) {
        let rotationTransformation = CGAffineTransform(rotationAngle: CGFloat(90).rad())
        
        borderFrame = frame
            .applying(rotationTransformation)
            .offsetBy(dx: nodeSide*4, dy: nodeSide*4)
            .insetBy(dx: -nodeSide*8, dy: -nodeSide*8)
        
        previousNodeTree = QuadTree(bounds: frame, subdivideTreshold: treeSubdivisionTreshold, minSubdivisionLenght: minimalDetectionRange)
        currentNodeTree = QuadTree(bounds: frame, subdivideTreshold: treeSubdivisionTreshold, minSubdivisionLenght: minimalDetectionRange)
        
        
        //DEBUG-PART
        if zoomOut {
            let cameraNode = SKCameraNode()
            cameraNode.position = CGPoint(x: 0, y: 150)
            addChild(cameraNode)
            camera = cameraNode
            camera?.setScale(3)
        }
        //DEBUG-PART

        
        //Physics of the world
        physicsWorld.contactDelegate = self
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: borderFrame)
        
        physicsBody?.contactTestBitMask = 1
        physicsBody?.collisionBitMask = 2
        physicsBody?.categoryBitMask = 0
        
        view.isPaused = true
        for _ in 0..<nodeCount {
            addNode()
        }
        view.isPaused = false

        
        //DEBUG-PART
        if pauseOnStart {
            view.isPaused = true
        }
        if debugMode {
            view.showsPhysics = true
        }
        //DEBUG-PART

        
    }
    
    //MARK: - Node creation
    func addNode() {
        let node = BoidNode(size: CGSize(width: nodeSide, height: nodeSide), texture: nodeTexture)
        
        //Location
        let randomX = CGFloat.random(in: frame.minX + nodeSide * 2...frame.maxX - nodeSide * 2)
        let randomY = CGFloat.random(in: frame.minY + nodeSide * 2...frame.maxY - nodeSide * 2)
        
        let randomPosition = CGPoint(x: randomX, y: randomY)
        node.position = randomPosition
        
        
        //Adding to important stuff
        nodeArray.append(node)
        previousNodeTree.addNode(node: node)
        addChild(node)
        
        
        //Movement
        let randomVelocityVector = CGVector(randomIn: minSpeed..<maxSpeed)
        node.physicsBody!.applyForce(randomVelocityVector)
        node.zRotation = -atan2(1, 0) + atan2(randomVelocityVector.dy,
                                             randomVelocityVector.dx)
                

    }
    
    //MARK: - Contact
//    func didBegin(_ contact: SKPhysicsContact) {
//        var node: SKNode!
//
//        if contact.bodyA.categoryBitMask == 0 && contact.bodyB.categoryBitMask == 1 ||
//            contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 0 {
//            node = contact.bodyA.categoryBitMask == 1 ? contact.bodyA.node : contact.bodyB.node
//
//            let x = node.position.x
//            let y = node.position.y
//
//            let maxTresholdX = borderFrame.maxX - nodeSide * 4
//            let minTresholdX = borderFrame.minX + nodeSide * 4
//            let maxTresholdY = borderFrame.maxY - nodeSide * 4
//            let minTresholdY = borderFrame.minY + nodeSide * 4
//
//            var movePoint = node.position
//
//            if x > maxTresholdX {
//                movePoint.x = minTresholdX
//            }
//            if x < minTresholdX {
//                movePoint.x = maxTresholdX
//            }
//            if y > maxTresholdX {
//                movePoint.y = minTresholdY
//            }
//            if y < minTresholdY {
//                movePoint.y = maxTresholdY
//            }
//
//            node.move(toPoint: movePoint)
//        }
//    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
       
    }
    
    func touchUp(atPoint pos : CGPoint) {
   
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //MARK: - Updating
    override func update(_ currentTime: TimeInterval) {
        updateCount += 1
        
        if updateCount % numberOfFramesBeforeUpdatingInfo == 0 {
            updateCount = 0
            
            currentNodeTree.clear()
            
            for node in nodeArray {
                checkIfInsideOfView(node: node)
                
                self.currentNodeTree.addNode(node: node)
                let neighbours = self.previousNodeTree.searchInSector(node: node)
                //                let searchRect = node.getSearchRect()
                //                let neighbours = self.previousNodeTree.search(searchRect: searchRect)
                
                node.setNeighbours(neighbours: neighbours) //All rules logic is inside of BoidNode class
                node.updateValues()
            }
            previousNodeTree = currentNodeTree
            
        } else {
            for node in nodeArray {
                node.updateValues()
            }
        }
    }
    
    private func checkIfInsideOfView(node: BoidNode) {
        let x = node.position.x
        let y = node.position.y
        
        let maxTresholdX = borderFrame.maxX - nodeSide * 4
        let minTresholdX = borderFrame.minX + nodeSide * 4
        let maxTresholdY = borderFrame.maxY - nodeSide * 4
        let minTresholdY = borderFrame.minY + nodeSide * 4
        
        var movePoint = node.position
        
        if x > maxTresholdX {
            movePoint.x = minTresholdX
        }
        if x < minTresholdX {
            movePoint.x = maxTresholdX
        }
        if y > maxTresholdX {
            movePoint.y = minTresholdY
        }
        if y < minTresholdY {
            movePoint.y = maxTresholdY
        }
        
        node.move(toPoint: movePoint)
    }
}
