//
//  Preferences.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 29.05.2023.
//

import Foundation

let nodeCount = 500

//Boid settings
let maxSpeed: CGFloat = 300
let minSpeed: CGFloat = 200
let maxForce: CGFloat = 50
let visionAngle: CGFloat = 120
let passiveAcceleration: CGFloat = 1.1

let minimalDetectionRange: CGFloat = 150
let separationDistance: CGFloat = 35
let randomness: CGFloat = 25
let minimalNeighboursCountToStopIncreasingRange = 5

let nodeSide: CGFloat = 25

//Modifiers
let cohesionModifier: CGFloat = 0.1
let separationModifier: CGFloat = 0.5
let alignmentModifier: CGFloat = 0.2

let rotationModifier: CGFloat = 0.3  //Bigger - faster rotation. 0.3 works best for me

//World settings
let borderMargin: CGFloat = 25
let treeSubdivisionTreshold: Int = 20 // 20 for 1500 nodes

let numberOfFramesBeforeUpdatingInfo: Int = 1//Every N frames tree and neighbours info will be recreated

//Debug
let debugMode = false
let pauseOnStart = false
let zoomOut = true
