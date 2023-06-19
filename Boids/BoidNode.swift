//
//  BoidNode.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 05.03.2023.
//

import SpriteKit
import simd

final class BoidNode: SKSpriteNode {
    private var currentSearchRadius: CGFloat = 0 //Search radius is increasing until current amount of neighbours is the same as minimalNeighboursCountToStopIncreasingRange
    private var currentNeighbours: [BoidNode] = []
    
    private var neighboursAlignment: CGVector?
    private var neighboursPosition: CGVector?
    
    
    init(size: CGSize, texture: SKTexture) {
        super.init(texture: texture, color: .red, size: size)
        
        //Physics
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.allowsRotation = true
        physicsBody?.affectedByGravity = false
        physicsBody?.linearDamping = 0
        physicsBody?.categoryBitMask = 1
        physicsBody?.collisionBitMask = 2
    }
    
    public func getSearchRect() -> CGRect {
        currentSearchRadius = max(currentSearchRadius, minimalDetectionRange)
        return CGRect(x: position.x - currentSearchRadius,
                      y: position.y - currentSearchRadius,
                      width: currentSearchRadius * 2,
                      height: currentSearchRadius * 2)
    }
    
    public func setNeighbours(neighbours: [BoidNode]) {
        currentNeighbours = neighbours
        updateNeighboursValues(neighbours: neighbours)
    }
    
    private func updateNeighboursValues(neighbours: [BoidNode]) {
        guard neighbours.count > 1 else {
            neighboursPosition = nil
            neighboursAlignment = nil
            return
        } //If no neighbours, stops exectuing next funcs and sets neighbour values to nil, to stop calculating rules' values
        
        var alignmentVector: CGVector = .zero
        var neighboursPosition: CGVector = .zero

        for neighbour in currentNeighbours {
            alignmentVector += neighbour.physicsBody!.velocity
            
            neighboursPosition.dx += neighbour.position.x
            neighboursPosition.dy += neighbour.position.y
        }
        
        neighboursAlignment = alignmentVector / CGFloat(currentNeighbours.count)
        neighboursPosition = neighboursPosition / CGFloat(currentNeighbours.count)
        
    }

    //MARK: Applying rules
    public func updateVelocity() {
        var sumVector: CGVector = .zero

        //Rules
        sumVector += alignmentRule()
        sumVector += cohesionRule()
        sumVector += separationRule()

        //Randomness
        var endingSteerVector: CGVector! = physicsBody!.velocity + sumVector * rotationModifier
        endingSteerVector.limit(minSpeed...maxSpeed)

        
        physicsBody!.velocity = endingSteerVector
                
        let steerAngle = atan2(1, 0) - atan2(endingSteerVector.dy,
                                             endingSteerVector.dx)
        
        //Rotation of the sprite
        zRotation = -steerAngle
    }
    
    //MARK: Rules
    //1-Cohesion: Steer towards average position of nearby boids
    //2-Alignment: Mantain a heading similar to average flock heading
    //3-Separtion: Keep distance between boids
    private func alignmentRule() -> CGVector {
        guard let _ = neighboursAlignment else { return .zero }

        return (neighboursAlignment! - physicsBody!.velocity) * alignmentModifier
    }
    
    private func cohesionRule() -> CGVector {
        guard let _ = neighboursPosition else { return .zero }

        return (neighboursPosition! - CGVector(dx: position.x, dy: position.y)) * cohesionModifier
    }
    
    private func separationRule() -> CGVector {
        if currentNeighbours.isEmpty { return .zero }
        
        var separationVector: CGVector = .zero
        
        for neighbour in currentNeighbours {
            let distance = neighbour.position.distance(to: position)
            if distance < sqrt(separationDistanceSquared) {
                let escapeVector = position - neighbour.position
                separationVector -= escapeVector * (100/distance)
            }
        }
        
        return separationVector * separationModifier
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
