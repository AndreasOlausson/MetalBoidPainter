//
//  Brush.swift
//  MetalBoidsPainter
//
//  Created by Andreas Olausson on 2024-10-25.
//


//
//  Brush.swift
//  Flocking
//
//  Created by Andreas Olausson on 2024-10-03.
//
import Foundation

enum BrushName: String {
    case thinLines = "Thin solid Lines"
    case thinOpacLines = "Thin opaque Lines"
    case thickLines = "Thick solid Lines"
    case thickOpacLines = "Thick opaque Lines"
    case decreasingWidth = "Decreasing width"
    
}

struct Brush {
    var strokeSize: CGFloat
    var opacity: CGFloat
}

class BrushManagerX {
    func getBrush(for iterationCount: Float) -> Brush {
        print(iterationCount)
        let normalizedIterationCount = iterationCount // TOOO: This could be iterationCount / number of boids for example
        switch normalizedIterationCount {
        case 0...2000:
            return Brush(
                strokeSize: 400,
                opacity: 0.005
            )
        case 2001...5000:
            return Brush(
                strokeSize: 200,
                opacity: 0.01
            )
        case 5001...10000:
            return Brush(
                strokeSize: 100,
                opacity: 0.05
            )
        case 10001...20000:
            return Brush(
                strokeSize: 10,
                opacity: 0.1
            )
        case 20001...100000:
            return Brush(
                strokeSize: 3,
                opacity: 0.2
            )
        default:
            return Brush(
                strokeSize: 0.2,
                opacity: 0.5
            )
        }
    }
}

class BrushManager {
    var config: BoidsConfig // Assumes BoidsConfig includes a brushSet property
    
    init(config: BoidsConfig) {
        self.config = config
    }
    
    func getBrush(for iterationCount: Float) -> Brush {
        print(iterationCount)
        let normalizedIterationCount = iterationCount // Can adjust normalization as needed
        
        // Select brush behavior based on the brush type from the config
        switch config.brushSet {
        case .thinLines:
            switch normalizedIterationCount {
            case 0...50000:
                return Brush(strokeSize: 0.5, opacity: 0.5)
            default:
                return Brush(strokeSize: 0.5, opacity: 0.2)
            }
            
        case .thinOpacLines:
            switch normalizedIterationCount {
            case 0...50000:
                return Brush(strokeSize: 0.5, opacity: 0.15)
            default:
                return Brush(strokeSize: 0.2, opacity: 0.2)
            }
            
        case .thickLines:
            switch normalizedIterationCount {
            case 0...2000:
                return Brush(strokeSize: 8.0, opacity: 0.5)
            case 2001...5000:
                return Brush(strokeSize: 6.0, opacity: 0.4)
            case 5001...10000:
                return Brush(strokeSize: 4.0, opacity: 0.3)
            default:
                return Brush(strokeSize: 2.0, opacity: 0.2)
            }
            
        case .thickOpacLines:
            switch normalizedIterationCount {
            case 0...2000:
                return Brush(strokeSize: 8.0, opacity: 0.05)
            case 2001...5000:
                return Brush(strokeSize: 6.0, opacity: 0.1)
            case 5001...10000:
                return Brush(strokeSize: 4.0, opacity: 0.15)
            default:
                return Brush(strokeSize: 2.0, opacity: 0.2)
            }
            
        case .decreasingWidth:
            switch normalizedIterationCount {
            case 0...2000:
                return Brush(
                    strokeSize: 400,
                    opacity: 0.005
                )
            case 2001...5000:
                return Brush(
                    strokeSize: 200,
                    opacity: 0.01
                )
            case 5001...10000:
                return Brush(
                    strokeSize: 100,
                    opacity: 0.05
                )
            case 10001...20000:
                return Brush(
                    strokeSize: 10,
                    opacity: 0.1
                )
            case 20001...100000:
                return Brush(
                    strokeSize: 3,
                    opacity: 0.2
                )
            default:
                return Brush(
                    strokeSize: 1,
                    opacity: 0.5
                )
            }
        }
    }
}

