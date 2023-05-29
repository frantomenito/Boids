//
//  Preferences.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 29.05.2023.
//

import Foundation

let nodeCount = 1500

//Boid settings
let maxSpeed: CGFloat = 600
let minSpeed: CGFloat = 500
let maxForce: CGFloat = 100
let passiveAcceleration: CGFloat = 1.1

let minimalDetectionRange: CGFloat = 30
let separationDistance: CGFloat = 40
let randomness: CGFloat = 25

let nodeSide: CGFloat = 25

//Modifiers
let cohesionModifier: CGFloat = 0.1
let separationModifier: CGFloat = 0.5
let alignmentModifier: CGFloat = 0.2


//World settings
let borderMargin: CGFloat = 25
let treeSubdivisionTreshold: Int = 20 // 20 for 1500 nodes

let numberOfFramesBeforeUpdatingInfo: Int = 5//Every N frames tree and neighbours will be recreated

//Debug
let debugMode = false
let pauseOnStart = false
let zoomOut = true
