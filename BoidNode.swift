//
//  BoidNode.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 05.03.2023.
//

import SpriteKit

class BoidNode: SKSpriteNode {
    
    private var currentSearchRadius: CGFloat = 0
    private var currentNeighbours: [BoidNode] = []
    
    var minimalDetectionRange: CGFloat = 25
    
    let minimalNeighboursCountToStopIncreasingRange = 5
    
    
    var maxSpeed: CGFloat = 600
    var minSpeed: CGFloat = 500
    var maxForce: CGFloat = 100
    var randomness: CGFloat = 25
    var passiveAcceleration: CGFloat = 1.1
    
    var separationDistance: CGFloat = 40

    
    var cohesionModifier: CGFloat = 0.1
    var separationModifier: CGFloat = 0.5
    var alignmentModifier: CGFloat = 0.2
        
    
    init(size: CGSize) {
        let texture = SKTexture(image: UIImage(named: "triangle")!)
        super.init(texture: texture, color: .red, size: size)
        
        //Physics
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0
        physicsBody?.categoryBitMask = 1
        physicsBody?.contactTestBitMask = 0
        physicsBody?.collisionBitMask = 2
        //        node.physicsBody?.usesPreciseCollisionDetection = true
    }

    
    //MARK: Rules
    //1-Cohesion: Steer towards average position of nearby boids
    //2-Alignment: Mantain a heading similar to average flock heading
    //3-Separtion: Keep distance between boids
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
