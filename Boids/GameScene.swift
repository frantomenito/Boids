//
//  GameScene.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 16.02.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Settings
    let nodeCount = 1500
    let minimalDetectionRange: CGFloat = 30
    let separationDistance: CGFloat = 40
    
    //Tree
    let treeSubdivisionTreshold: Int = 20 // 20 for 1500 nodes
    let treeUpdateCount = 5//Tree updates every N frames
    
    
    //Modifiers
    let cohesionModifier: CGFloat = 0.1
    let separationModifier: CGFloat = 0.5
    let alignmentModifier: CGFloat = 0.2
    
    //World settings

    let maxSpeed: CGFloat = 600
    let minSpeed: CGFloat = 500
    let maxForce: CGFloat = 100
    let randomness: CGFloat = 25
    let passiveAcceleration: CGFloat = 1.1
    
    let borderMargin: CGFloat = 25
    let nodeSide: CGFloat = 25
    
    //Global variables
    var borderFrame: CGRect = .zero
    var nodeArray: [BoidNode] = []
    var previousNodeTree: QuadTree!
    var currentNodeTree: QuadTree!
    var updateCount: Int = 0

    
    //Debug
    let debugMode = false
    let pauseOnStart = false
    let zoomOut = false

    //MARK: - DidMove
    override func didMove(to view: SKView) {
        
        let scalingTransformation = CGAffineTransform(scaleX: 1, y: 0.5)
        
        borderFrame = frame
            .applying(scalingTransformation)
            .offsetBy(dx: nodeSide*4, dy: nodeSide*4)
            .insetBy(dx: -nodeSide*8, dy: -nodeSide*8)
        
        //DEBUG-PART
        if zoomOut {
            let cameraNode = SKCameraNode()
            cameraNode.position = CGPoint(x: 0, y: 150)
            addChild(cameraNode)
            camera = cameraNode
            camera?.setScale(3)
        }
        //DEBUG-PART

        
        previousNodeTree = QuadTree(bounds: frame, subdivideTreshold: treeSubdivisionTreshold, minSubdivisionLenght: minimalDetectionRange)
        currentNodeTree = QuadTree(bounds: frame, subdivideTreshold: treeSubdivisionTreshold, minSubdivisionLenght: minimalDetectionRange)
        
        for _ in 0..<nodeCount {
            addNode()
        }
        
        physicsWorld.contactDelegate = self
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: borderFrame)
        
        physicsBody?.contactTestBitMask = 1
        physicsBody?.collisionBitMask = 2
        physicsBody?.categoryBitMask = 0
        
        
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
        let node = BoidNode(size: CGSize(width: nodeSide, height: nodeSide))
        
        //Location
        let randomX = CGFloat.random(in: borderFrame.minX + nodeSide * 2...borderFrame.maxX - nodeSide * 2)
        let randomY = CGFloat.random(in: borderFrame.minY + nodeSide * 2...borderFrame.maxY - nodeSide * 2)
        
        let randomPosition = CGPoint(x: randomX, y: randomY)
        node.position = randomPosition
        
        //Movement
        let randomVelocityVector = CGVector(randomIn: minSpeed..<maxSpeed)
        node.physicsBody?.applyForce(randomVelocityVector)
        node.zRotation = -atan2(1, 0) + atan2(randomVelocityVector.dy,
                                             randomVelocityVector.dx)
        
        //Adding to important stuff
        nodeArray.append(node)
        previousNodeTree.addNode(node: node)
        addChild(node)
        
        //Giving node correct preferences
        node.maxForce = maxForce
        node.maxSpeed = maxSpeed
        node.minSpeed = minSpeed
        node.minimalDetectionRange = minimalDetectionRange
        node.alignmentModifier = alignmentModifier
        node.cohesionModifier = cohesionModifier
        node.separationModifier = separationModifier
        node.separationDistance = separationDistance
        node.passiveAcceleration = passiveAcceleration
        node.randomness = randomness
    }
    
    //MARK: - Contact
    func didBegin(_ contact: SKPhysicsContact) {
        var node: SKNode!
                
        if contact.bodyA.categoryBitMask == 0 && contact.bodyB.categoryBitMask == 1 ||
            contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 0 {
            node = contact.bodyA.categoryBitMask == 1 ? contact.bodyA.node : contact.bodyB.node
            
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
    
    //MARK: - Updating / Rules
    

    override func update(_ currentTime: TimeInterval) {
        
        updateCount += 1
        
        for node in nodeArray {
//            nodeTree.remove(node)
            let searchRect = node.getSearchRect()
            let neighbours = self.previousNodeTree.search(searchRect: searchRect)
            
            node.updateValues(neighbours: neighbours) //All rules logic is inside of BoidNode class
        }
        
        if updateCount == treeUpdateCount {
            updateCount = 0
            currentNodeTree.clear()

            for node in nodeArray {
                self.currentNodeTree.addNode(node: node)
            }
            
            previousNodeTree = currentNodeTree
        }
    }
}

//MARK: - Extensions
extension CGFloat {
    func rad() -> CGFloat {
        return self * (.pi / 180)
    }
    
    func grad() -> CGFloat {
        return self * (180 / .pi)
    }
}

extension SKNode {
    func rotateForce(by degrees: CGFloat) {
        let oldVelocity = physicsBody!.velocity
        
        let myCos = cos(degrees)
        let mySin = sin(degrees)

        let rotationMatrixColumn1 = simd_double2(Double(myCos), -Double(mySin))
        let rotationMatrixColumn2 = simd_double2(Double(mySin), Double(myCos))
        let rotationMatrix = simd_double2x2(rows: [rotationMatrixColumn1,
                                                      rotationMatrixColumn2])

        let vectorMatrix = simd_double2(Double(oldVelocity.dx), Double(oldVelocity.dy))

        let rotatedVector = matrix_multiply(rotationMatrix, vectorMatrix)

        
        let newVelocity = CGVector(dx: rotatedVector.x, dy: rotatedVector.y)
        physicsBody?.velocity = newVelocity
    }
    
    func move(toPoint: CGPoint) {
        let move = SKAction.run {
            self.position = toPoint
        }
        run(move)
    }
}

extension SKScene {
    func nodesInRange(point: CGPoint, range: CGFloat) -> [SKNode] {
        return self
            .children
            .filter {
                let distanceToNode = $0.position.distance(point: point)
                return distanceToNode <= range && distanceToNode != 0
            }
    }
}

extension CGPoint {
    func distance(point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - self.x), Float(point.y - self.y)))
    }
    
    static func /=(point: inout CGPoint, value: CGFloat) {
        point.x /= value
        point.y /= value
    }
    
    static func +=(lpoint: inout CGPoint, rpoint: CGPoint) {
        lpoint.x += rpoint.x
        lpoint.y += rpoint.y
    }
}

extension CGVector {
    static func /=(vector: inout CGVector, value: CGFloat) {
        vector.dx /= value
        vector.dy /= value
    }
    
    static func /(vector: CGVector, value: CGFloat) -> CGVector {
        return CGVector(dx: vector.dx / value,
                        dy: vector.dy / value)
    }
    
    static func +=(lvector: inout CGVector, rvector: CGVector) {
        lvector.dx += rvector.dx
        lvector.dy += rvector.dy
    }
    static func *=(lvector: inout CGVector, rvector: CGVector) {
        lvector.dx *= rvector.dx
        lvector.dy *= rvector.dy
    }
    static func *=(lvector: inout CGVector, rvalue: CGFloat) {
        lvector.dx *= rvalue
        lvector.dy *= rvalue
    }
    
    static func +(lvector: CGVector, rvector: CGVector) -> CGVector {
        return CGVector(dx: lvector.dx + rvector.dx,
                        dy: lvector.dy + rvector.dy)
        
    }
    static func -(lvector: CGVector, rvector: CGVector) -> CGVector {
        return CGVector(dx: lvector.dx - rvector.dx,
                        dy: lvector.dy - rvector.dy)
        
    }
    static func *(lvector: CGVector, rvector: CGVector) -> CGVector {
        return CGVector(dx: lvector.dx * rvector.dx,
                        dy: lvector.dy * rvector.dy)
        
    }
    
    static func *(lvector: CGVector, rvalue: CGFloat) -> CGVector {
        return CGVector(dx: lvector.dx * rvalue,
                        dy: lvector.dy * rvalue)
        
    }
    
    static func -=(lvector: inout CGVector, rvector: CGVector) {
        lvector.dx -= rvector.dx
        lvector.dy -= rvector.dy
    }
    
    static func -=(lvector: inout CGVector, rvalue: CGFloat) {
        lvector.dx -= rvalue
        lvector.dy -= rvalue
    }
    
    init(randomIn: Range<CGFloat>) {
        let randomDirection = CGVector(dx: Double.random(in: -100.0...100.0),
                                    dy: Double.random(in: -100.0...100.0))
        let randomForce = CGFloat.random(in: randomIn)
        self = randomDirection.normalized() * randomForce
    }

    
    func angleRadians() -> CGFloat {
        return atan2(dy, dx)
    }
    
    func angleDegrees() -> CGFloat {
        return angleRadians() * 180.0 / .pi
    }
    
    var lenght: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector {
        let calculatedLenght = lenght
        return calculatedLenght > 0 ? self / calculatedLenght : .zero
    }
    
    mutating func limit(_ forceRange: ClosedRange<CGFloat>) {
        if lenght > forceRange.upperBound {
            self = normalized() * forceRange.upperBound
        } else if lenght < forceRange.lowerBound {
            self = normalized() * forceRange.lowerBound
        }
    }
    
    mutating func limit(_ force: CGFloat) {
        if lenght > force {
            self = normalized() * force
        }
    }
}
