//
//  GameScene.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 16.02.2023.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Global variables
    var nodeArray: [BoidNode] = []
    var updateCount: Int = 0
    
    var previousNodeTree: SpatialHashGrid!
    var currentNodeTree: SpatialHashGrid!
    
    let nodeTexture = SKTexture(image: UIImage(named: "triangle")!) //Using the same texture to reduce amount of draws. See https://developer.apple.com/documentation/spritekit/nodes_for_scene_building/maximizing_node_drawing_performance

    
    //MARK: - DidMove
    override func didMove(to view: SKView) {
        previousNodeTree = SpatialHashGrid(cellSize: detectionRange)
        currentNodeTree = SpatialHashGrid(cellSize: detectionRange)
        
        //camera
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: 0, y: 0)
        addChild(cameraNode)
        camera = cameraNode
        
        //Nodes creation
        view.isPaused = true
        for _ in 0..<nodeCount {
            addNode()
        }
        view.isPaused = false

        
        //DEBUG
        if zoomOut {
            camera?.setScale(1.5)
        }
        
        if pauseOnStart {
            view.isPaused = true
        }
        
        if showSearchAlgorithm {
            previousNodeTree.draw(in: self)
        }
        //DEBUG
    }
    
    //MARK: - Node creation
    func addNode() {
        let node = BoidNode(size: CGSize(width: nodeSide, height: nodeSide), texture: nodeTexture)
        
        //Location
        let randomX = CGFloat.random(in: frame.minX...frame.maxX)
        let randomY = CGFloat.random(in: frame.minY...frame.maxY)
        
        let randomPosition = CGPoint(x: randomX, y: randomY)
        node.position = randomPosition
        
        
        //Adding to arrays
        nodeArray.append(node)
        previousNodeTree.addNode(node: node)
        addChild(node)
        
        
        //Movement
        let randomVelocityVector = CGVector(randomIn: minSpeed..<maxSpeed)
        node.velocity = randomVelocityVector
        node.zRotation = -atan2(1, 0) + atan2(randomVelocityVector.dy,
                                             randomVelocityVector.dx)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        setNodesTouchLocation(touch: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        setNodesTouchLocation(touch: pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        removeNodesTouchLocation()
    }
    
    func setNodesTouchLocation(touch: CGPoint) {
        for node in nodeArray {
            node.setTouchLocation(touch: touch)
        }
    }
    
    func removeNodesTouchLocation() {
        for node in nodeArray {
            node.removeTouchLocation()
        }
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
                let neighbours = self.previousNodeTree.searchNodesInRange(from: node.position,
                                                                          range: detectionRange)
                
                node.setNeighbours(neighbours: neighbours) //All rules logic is inside of BoidNode class
                
                
            }
            
            DispatchQueue.concurrentPerform(iterations: nodeArray.count) { i in
                let node = nodeArray[i]
                
                node.updateVelocity()
            }
            
            previousNodeTree = currentNodeTree
        } else {
            DispatchQueue.concurrentPerform(iterations: nodeArray.count) { i in
                let node = nodeArray[i]
                
                node.updateVelocity()
            }
        }
    }
    
    private func checkIfInsideOfView(node: BoidNode) {
        let x = node.position.x
        let y = node.position.y
        
        let maxTresholdX = frame.maxX
        let minTresholdX = frame.minX
        let maxTresholdY = frame.maxY
        let minTresholdY = frame.minY
        
        var movePoint = node.position
        
        if x > maxTresholdX {
            movePoint.x -= frame.width
        }
        if x < minTresholdX {
            movePoint.x += frame.width
        }
        if y > maxTresholdY {
            movePoint.y -= frame.height
        }
        if y < minTresholdY {
            movePoint.y += frame.height
        }
        
        node.position = movePoint
    }
}
