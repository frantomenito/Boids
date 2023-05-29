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
        
    let minimalNeighboursCountToStopIncreasingRange = 5
    
    init(size: CGSize, texture: SKTexture) {
        super.init(texture: texture, color: .red, size: size)
        
        //Physics
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0
        physicsBody?.categoryBitMask = 1
        physicsBody?.contactTestBitMask = 0
        physicsBody?.collisionBitMask = 2
    }
    
    func getSearchRect() -> CGRect {
        currentSearchRadius = max(currentSearchRadius, minimalDetectionRange)
        return CGRect(x: position.x - currentSearchRadius,
                      y: position.y - currentSearchRadius,
                      width: currentSearchRadius * 2,
                      height: currentSearchRadius * 2)
    }
    
    func setNeighbours(neighbours: [BoidNode]) {
        currentNeighbours = neighbours
    }
    
    func updateValues() {
        if currentNeighbours.count < minimalNeighboursCountToStopIncreasingRange {
            currentSearchRadius += 1.0 / CGFloat(minimalNeighboursCountToStopIncreasingRange - currentNeighbours.count)
        } else {
            currentSearchRadius = minimalDetectionRange
        }
        
        DispatchQueue.global().async {
            self.updateVelocity()
        }
    }
    
    
    
    //MARK: Rules
    //1-Cohesion: Steer towards average position of nearby boids
    //2-Alignment: Mantain a heading similar to average flock heading
    //3-Separtion: Keep distance between boids
    
    private func updateVelocity() {
        var flockPosition: CGPoint = .zero
        var separationVector: CGVector = .zero
        var alignmentVector: CGVector = .zero
        
        var rulesSumVector: CGVector = .zero
        
        for neighbour in currentNeighbours {
            //Alignment
            alignmentVector += neighbour.physicsBody!.velocity

            //Separtion
            if position.distance(to: neighbour.position) <= separationDistance {
                var smallSeparationVector: CGVector = CGVector(dx: position.x - neighbour.position.x,
                                                               dy: position.y - neighbour.position.y)
                let value = abs(smallSeparationVector.lenght - separationDistance)
                smallSeparationVector = smallSeparationVector.normalized()*log10(value)*value
                separationVector += smallSeparationVector
            }
            
            //Cohesion
            flockPosition += neighbour.position
        }
        
        
        if !currentNeighbours.isEmpty {
            //Alignment
            alignmentVector /= CGFloat(currentNeighbours.count)
            alignmentVector -= physicsBody!.velocity
            alignmentVector *= alignmentModifier
            
            //Separation

            separationVector -= physicsBody!.velocity
            separationVector *= separationModifier
            
            
            //Cohesion
            
            flockPosition /= CGFloat(currentNeighbours.count)
            var cohesionVector = CGVector(dx: flockPosition.x - position.x,
                                          dy: flockPosition.y - position.y)
            
            cohesionVector -= physicsBody!.velocity
            cohesionVector *= cohesionModifier
            
            //Adding all vectors
            rulesSumVector = separationVector + alignmentVector + cohesionVector
        }
        
        rulesSumVector -= CGVector(randomIn: -randomness..<randomness)
        rulesSumVector.limit(0...maxForce)

        var endingSteerVector: CGVector! = physicsBody!.velocity + rulesSumVector
        endingSteerVector.limit(minSpeed...maxSpeed)

        
        //Randomness
        endingSteerVector *= passiveAcceleration
        physicsBody!.velocity = endingSteerVector
        
        let steerAngle = atan2(1, 0) - atan2(endingSteerVector.dy,
                                             endingSteerVector.dx)
        
        //Rotation of the sprite
        zRotation = -steerAngle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
