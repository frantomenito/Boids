//
//  BoidNode.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 05.03.2023.
//

import SpriteKit
import simd

final class BoidNode: SKSpriteNode {
    private var currentNeighbours: [BoidNode] = []
    
    private var neighboursAlignment: CGVector?
    private var neighboursPosition: CGVector?
    
    private var touchLocation: CGPoint? //Much better idea is to make global value, becuase every single node is using the same touchLocation, so when we change it, we dont need to go through every single one of them
    
    public var velocity: CGVector = .zero
    
    init(size: CGSize, texture: SKTexture) {
        super.init(texture: texture, color: .red, size: size)
    }
    
    //MARK: Helper funcs
    public func getSearchRect() -> CGRect {
        return CGRect(x: position.x - detectionRange,
                      y: position.y - detectionRange,
                      width: detectionRange * 2,
                      height: detectionRange * 2)
    }
    
    public func setNeighbours(neighbours: [BoidNode]) {
        currentNeighbours = neighbours
        updateNeighboursValues(neighbours: neighbours)
    }
    
    private func updateNeighboursValues(neighbours: [BoidNode]) {
        guard neighbours.count > 1 else {  //If no neighbours, stops exectuing next funcs and sets neighbour values to nil, to stop calculating rules' values
            neighboursPosition = nil
            neighboursAlignment = nil
            return
        }
        
        var alignmentVector: CGVector = .zero
        var neighboursPosition: CGVector = .zero

        for neighbour in currentNeighbours {
            alignmentVector += neighbour.velocity
            
            neighboursPosition.dx += neighbour.position.x
            neighboursPosition.dy += neighbour.position.y
        }
        
        neighboursAlignment = alignmentVector / CGFloat(currentNeighbours.count)
        neighboursPosition = neighboursPosition / CGFloat(currentNeighbours.count)
        
    }
    
    public func updatePosition() {
        let newPosition = velocity * 0.05 + position
        position = newPosition.toPoint
        
        let steerAngle = atan2(1, 0) - atan2(velocity.dy, velocity.dx)
        zRotation = -steerAngle
    }
    
    public func setTouchLocation(touch: CGPoint) {
        touchLocation = touch
    }
    
    public func removeTouchLocation() {
        touchLocation = nil
    }

    //MARK: Applying rules
    public func updateVelocity() {
        var sumVector: CGVector = .zero

        //Rules
        sumVector += alignmentRule()
        sumVector += cohesionRule()
        sumVector += separationRule()
        sumVector += touchRule()

        //Randomness
        var endingSteerVector: CGVector! = velocity + sumVector * rotationModifier
        endingSteerVector.limit(minSpeed...maxSpeed)

        
        velocity = endingSteerVector
        updatePosition()
    }
    
    //MARK: Rules
    //1-Cohesion: Steer towards average position of nearby boids
    //2-Alignment: Mantain a heading similar to average flock heading
    //3-Separtion: Keep distance between boids
    //4-Touch: Boid move from touch location
    
    private func alignmentRule() -> CGVector {
        guard let _ = neighboursAlignment else { return .zero }

        return (neighboursAlignment! - velocity) * alignmentModifier
    }
    
    private func cohesionRule() -> CGVector {
        guard let _ = neighboursPosition else { return .zero }

        return (neighboursPosition! - CGVector(dx: position.x, dy: position.y)) * cohesionModifier
    }
    
    private func separationRule() -> CGVector {
        if currentNeighbours.isEmpty { return .zero }
        
        var separationVector: CGVector = .zero
        
        for neighbour in currentNeighbours {
            let distance = neighbour.position.squaredDistance(to: position)
            if distance < separationDistanceSquared {
                let escapeVector = position - neighbour.position
                separationVector -= escapeVector * (100/distance)
            }
        }
        
        return separationVector * separationModifier
    }
    
    private func touchRule() -> CGVector {
        guard let touchLocation = touchLocation else { return .zero }
        
        var escapeVector = CGVector.zero
        
        let distance = position.squaredDistance(to: touchLocation)
        if distance < touchDistanceSquared {
            escapeVector = (position - touchLocation).toVector * touchModifier
        }
        
        return escapeVector
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
