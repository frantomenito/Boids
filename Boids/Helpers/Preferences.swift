//
//  Preferences.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 29.05.2023.
//

import Foundation

//World settings
let nodeCount: Int = 3000
let numberOfFramesBeforeUpdatingInfo: Int = 3//Every N frames searchAlgorithm structure and neighbours info will be recreated


//Boid settings
let maxSpeed: CGFloat = 80
let minSpeed: CGFloat = 60

let nodeSide: CGFloat = 5
let detectionRange: CGFloat = 40
let detectionRangeSquared: CGFloat = {
    return detectionRange * detectionRange
}()

let separationDistanceSquared: CGFloat = 60
let touchDistanceSquared: CGFloat = 8000

//Modifiers
let cohesionModifier: CGFloat = 0.3
let separationModifier: CGFloat = 0.4
let alignmentModifier: CGFloat = 0.3
let touchModifier: CGFloat = 0.8

let rotationModifier: CGFloat = 0.2  //Bigger - faster rotation. 0.2 works best


//Debug
let showSearchAlgorithm = false
let pauseOnStart = false
let zoomOut = false
