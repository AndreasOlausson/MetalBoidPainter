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

struct Brush {
    var strokeSize: CGFloat
    var opacity: CGFloat
}

class BrushManager {
    func getBrush(for iterationCount: Float) -> Brush {
        print(iterationCount)
        let normalizedIterationCount = iterationCount
        switch normalizedIterationCount {
       /* case 0...2000:
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
        case 20001...40000:
            return Brush(
                strokeSize: 3,
                opacity: 0.2
            )*/
        default:
            return Brush(
                strokeSize: 0.2,
                opacity: 0.5
            )
        }
    }
}

