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
        let nodeGridKey = getGridKey(for: point)
        
        var nodesInRange = [BoidNode]()
        
        for x in nodeGridKey.x-1...nodeGridKey.x+1 {
            for y in nodeGridKey.y-1...nodeGridKey.y+1 {
                let gridKey = GridKey(x: x, y: y)
                if let nodes = grid[gridKey] {
                    for node in nodes {
                        let dx = node.position.x - point.x
                        let dy = node.position.y - point.y
                        let squaredDistance = dx * dx + dy * dy //Using squared distance, to remove division from calculation
                        
                        if squaredDistance <= minimalDetectionRangeSquared && squaredDistance != 0 {
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
