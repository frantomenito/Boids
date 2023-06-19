//
//  Preferences.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 29.05.2023.
//

import Foundation

let nodeCount = 3000

//Boid settings
let maxSpeed: CGFloat = 80
let minSpeed: CGFloat = 60
let visionAngle: CGFloat = 100
let passiveAcceleration: CGFloat = 1.1

let nodeSide: CGFloat = 5
let minimalDetectionRange: CGFloat = 40
let minimalDetectionRangeSquared: CGFloat = {
    return minimalDetectionRange * minimalDetectionRange
}()

let separationDistanceSquared: CGFloat = 30
let randomness: CGFloat = 25
let minimalNeighboursCountToStopIncreasingRange = 5


//Modifiers
let cohesionModifier: CGFloat = 0.3
let separationModifier: CGFloat = 0.4
let alignmentModifier: CGFloat = 0.2

let rotationModifier: CGFloat = 0.2  //Bigger - faster rotation. 0.2 works best

//World settings
let borderMargin: CGFloat = 25
let treeSubdivisionTreshold: Int = 10 // 20 for 1500 nodes

let numberOfFramesBeforeUpdatingInfo: Int = 3//Every N frames tree and neighbours info will be recreated

//Debug
let debugMode = false
let showTree = true
let pauseOnStart = false
let zoomOut = false
