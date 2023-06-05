//
//  Extensions.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 29.05.2023.
//

import Foundation
import SpriteKit

extension CGPoint {
    func rotatedPoint(around: CGPoint, byDegrees degrees: CGFloat) -> CGPoint {
        let dx = x - around.x
        let dy = y - around.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx)
        let newAzimuth = azimuth + degrees.rad()
        
        let x = around.x + radius * cos(newAzimuth)
        let y = around.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
    
    func isInsideSector(center: CGPoint, sectorStart: CGPoint, sectorEnd: CGPoint, radiusSquared: CGFloat) -> Bool {
        let relevantPoint = CGPoint(x: x - center.x,
                                    y: y - center.y)
        
        return !areClockwise(p1: sectorStart, p2: relevantPoint) &&
        areClockwise(p1: sectorEnd, p2: relevantPoint) &&
        isWithinRadius(point: relevantPoint, radiusSquared: radiusSquared)
    }
    
    func areClockwise(p1: CGPoint, p2: CGPoint) -> Bool {
        return -p1.x * p2.y + p1.y * p2.x > 0
    }
    
    func isWithinRadius(point: CGPoint, radiusSquared: CGFloat) -> Bool {
        let xSquared = point.x * point.x
        let ySquared = point.y * point.y
        return xSquared + ySquared <= radiusSquared
    }
    
    func distance(to: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(to.x - self.x), Float(to.y - self.y)))
    }
    
    static func /=(point: inout CGPoint, value: CGFloat) {
        point.x /= value
        point.y /= value
    }
    
    static func +=(lpoint: inout CGPoint, rpoint: CGPoint) {
        lpoint.x += rpoint.x
        lpoint.y += rpoint.y
    }
    
    static func -(lpoint: CGPoint, rpoint: CGPoint) -> CGPoint {
        return CGPoint(x: lpoint.x-rpoint.x,
                       y: lpoint.y-rpoint.y)
    }
    static func *(point: CGPoint, rvalue: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * rvalue,
                       y: point.y * rvalue)
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
    static func -=(lvector: inout CGVector, rvector: CGPoint) {
        lvector.dx += rvector.x
        lvector.dy += rvector.y
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
                let distanceToNode = $0.position.distance(to: point)
                return distanceToNode <= range && distanceToNode != 0
            }
    }
}
