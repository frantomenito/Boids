//
//  SpatialHashing.swift
//  Boids
//
//  Created by Dmytro Maksymyak on 06.06.2023.
//

import SpriteKit

class SpatialHashGrid {
    var cellSize: CGFloat
    var grid: [GridKey: [BoidNode]]
    
    init(cellSize: CGFloat) {
        self.cellSize = cellSize
        self.grid = [:]
    }
    
    func addNode(node: BoidNode) {
        let key = getGridKey(for: node.position)
        
        if grid[key] == nil {
            grid[key] = []
        }
        grid[key]!.append(node)
        
    }
    
    func getNodesInCell(at position: CGPoint) -> [BoidNode] {
        let gridKey = getGridKey(for: position)
        return grid[gridKey] ?? []
    }
    
    func getGridKey(for position: CGPoint) -> GridKey {
        let x = Int(position.x / cellSize)
        let y = Int(position.y / cellSize)
        return GridKey(x: x, y: y)
    }
    
    func searchNodesInRange(from point: CGPoint, range: CGFloat) -> [BoidNode] {
        let minX = Int((point.x - range) / cellSize)
        let maxX = Int((point.x + range) / cellSize)
        let minY = Int((point.y - range) / cellSize)
        let maxY = Int((point.y + range) / cellSize)
        
        var nodesInRange = [BoidNode]()
        
        for x in minX...maxX {
            for y in minY...maxY {
                let gridKey = GridKey(x: x, y: y)
                if let nodes = grid[gridKey] {
                    for node in nodes {
                        let distance = node.position.distance(to: point)
                        if distance <= range && distance != 0 {
                            nodesInRange.append(node)
                        }
                    }
                }
            }
        }
        return nodesInRange
    }
    
    func clear() {
        grid = [:]
    }
}

struct GridKey: Hashable {
    let x: Int
    let y: Int
}
