import UIKit
import MetalKit

struct HistoricPosition {
    var position: CGPoint
    var color: UIColor
}
struct Vector3 {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat = 0.0
    
    // Addition av två vektorer
    static func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    // Subtraktion av två vektorer
    static func -(lhs: Vector3, rhs: Vector3) -> Vector3 {
        return Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    // Multiplikation av en vektor och ett tal
    static func *(lhs: Vector3, rhs: CGFloat) -> Vector3 {
        return Vector3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    // Division av en vektor och ett tal
    static func /(lhs: Vector3, rhs: CGFloat) -> Vector3 {
        return Vector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    
    // Operator för tilldelning vid addition
    static func +=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs + rhs
    }
    
    // Operator för tilldelning vid subtraktion
    static func -=(lhs: inout Vector3, rhs: Vector3) {
        lhs = lhs - rhs
    }
    
    // Operator för tilldelning vid division
    static func /=(lhs: inout Vector3, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    
    // Beräkna magnituden av vektorn
    func magnitude() -> CGFloat {
        return sqrt(x * x + y * y + z * z)
    }
    
    // Normalisera vektorn
    func normalized() -> Vector3 {
        let mag = magnitude()
        return mag > 0 ? self / mag : Vector3(x: 0, y: 0, z: 0)
    }
    
    // Beräkna avståndet mellan två vektorer
    func distance(to vector: Vector3) -> CGFloat {
        return (self - vector).magnitude()
    }
    // Rotate the vector by a given angle in degrees
    func rotated(by angle: CGFloat) -> Vector3 {
        let radians = angle * .pi / 180
        let cosAngle = cos(radians)
        let sinAngle = sin(radians)
        
        let rotatedX = x * cosAngle - y * sinAngle
        let rotatedY = x * sinAngle + y * cosAngle
        return Vector3(x: rotatedX, y: rotatedY, z: z)
    }
}
extension Vector3 {
    func toCGPoint() -> CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
}
extension Vector3 {
    init(from point: CGPoint) {
        self.x = point.x
        self.y = point.y
        self.z = 0.0
    }
}

func -(lhs: CGPoint, rhs: CGPoint) -> Vector3 {
    return Vector3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: 0)
}
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
extension CGPoint {
    mutating func add(_ vector: Vector3) {
        self.x += vector.x
        self.y += vector.y
    }
}
enum DriftDirection {
    case left
    case right
}
class BoidNode: CAShapeLayer {
    //var position: CGPoint = .zero
    //var path: CGPath?
    //var strokeColor: CGColor = UIColor.red.cgColor
    //var fillColor: CGColor = UIColor.white.cgColor
    //var lineWidth: CGFloat = 1.0
    var alpha: CGFloat = 1.0
    //var zPosition: CGFloat = 0
    //var name: String?
    var children: [BoidNode] = []
    var velocity: Vector3 = Vector3(x: 0, y: 0, z: 0)
    var historicPositions: [HistoricPosition] = []
    
    var isDrifting: Bool = false
    var driftDirection: DriftDirection = .left  // .left or .right
    var driftAngle: CGFloat = 0.0
    var driftRemainingFrames: Int = 0
    
    
    func addChild(_ node: BoidNode) {
        children.append(node)
    }
    func addHistoricPosition(_ position: CGPoint, color: UIColor, maxHistoricPositions: Int) {
        // Lägg till ny historik
        let newHistoricPosition = HistoricPosition(position: position, color: color)
        historicPositions.append(newHistoricPosition)
        
        // Om arrayen är full, ta bort den äldsta posten
        if historicPositions.count > maxHistoricPositions {
            historicPositions.removeFirst()
        }
    }
}
struct BoidsConfig {
    var numberOfBoids = 250
    var numberOfPredators = 4
    var speedFactor: CGFloat = 1.2
    var doPaint: Bool = true
    var maxHistoricPositions = 10
    
    var maxSpeed: CGFloat
    var avoidanceRange: CGFloat
    var alignmentRange: CGFloat
    var cohesionRange: CGFloat
    var fleeRange: CGFloat
    var edgeThreshold: CGFloat
    
    var avoidanceFactor: CGFloat
    var alignmentFactor: CGFloat
    var cohesionFactor: CGFloat
    var fleeFactor: CGFloat
    var edgeAvoidanceFactor: CGFloat
    
    var panicFlightSpeed: CGFloat
    var panicFlightRange: CGFloat
    var panicFlightWeight: CGFloat
    
    var predatorSpeed: CGFloat
    var predatorTurnSpeed: CGFloat
    var predatorVisualRange: CGFloat
    var predatorHuntingRange: CGFloat
    var predatorModerateSpeed: CGFloat
    var predatorAggressiveSpeed: CGFloat
    var predatorDriftFactor: CGFloat
    var predatorChaseRange: CGFloat
    
    var driftPercentage: CGFloat
    
    var showAlignmentRange: Bool
    var showAvoidanceRange: Bool
    var showCohesionRange: Bool
    var showFleeRange: Bool
    var showPredatorOuterRing: Bool
    var showPredatorInnerRing: Bool
    var showOnlyAlphaBoid: Bool
    var showOnlyAlphaPredator: Bool
    var showBoidView: Bool
    var showArtView: Bool
    var showImageView: Bool
    
    init(speedFactor: CGFloat = 2.0) {
        self.speedFactor = speedFactor
        
        self.maxSpeed = 4.0 * speedFactor
        
        //Ranges
        //Boid
        self.avoidanceRange = 12.0
        self.alignmentRange = 28.0
        self.cohesionRange = 71.0
        self.fleeRange = 50.0
        self.edgeThreshold = 100.0
        self.panicFlightRange = 30.0
        //Predator
        self.predatorVisualRange = 100.0
        self.predatorHuntingRange = 25.0
        self.predatorChaseRange = 150.0
        
        //Factor/Weights
        //Boid
        self.avoidanceFactor = 1.0
        self.alignmentFactor = 0.44
        self.cohesionFactor = 0.08
        self.fleeFactor = 1.3
        self.edgeAvoidanceFactor = 2.0
        
        //Predator
        
        
        //Speed
        self.panicFlightSpeed = 4.0 * speedFactor
        
        
        
        self.panicFlightWeight = 3.0
        
        self.predatorSpeed = 2.5 * speedFactor
        self.predatorTurnSpeed = 2.0 * speedFactor
        
        self.predatorModerateSpeed = 1.5 * speedFactor
        self.predatorAggressiveSpeed = 3.0 * speedFactor
        self.predatorDriftFactor = 0.1
        
        
        self.driftPercentage = 0.1
        
        /*
         self.maxSpeed = 4.0 * speedFactor
         self.avoidanceRange = 12.0 * speedFactor
         self.alignmentRange = 28.0 * speedFactor
         self.cohesionRange = 71.0 * speedFactor
         self.fleeRange = 50.0 * speedFactor
         self.edgeThreshold = 100.0 * speedFactor
         
         self.avoidanceFactor = 1.0
         self.alignmentFactor = 0.44
         self.cohesionFactor = 0.08
         self.fleeFactor = 1.3
         self.edgeAvoidanceFactor = 2.0
         
         self.panicFlightSpeed = 4.0 * speedFactor
         self.panicFlightRange = 30.0 * speedFactor
         self.panicFlightWeight = 3.0
         
         self.predatorSpeed = 2.5 * speedFactor
         self.predatorTurnSpeed = 2.0 * speedFactor
         self.predatorVisualRange = 100.0 * speedFactor
         self.predatorHuntingRange = 25.0 * speedFactor
         self.predatorModerateSpeed = 1.5 * speedFactor
         self.predatorAggressiveSpeed = 3.0 * speedFactor
         self.predatorDriftFactor = 0.1
         self.predatorChaseRange = 150.0 * speedFactor
         
         self.driftPercentage = 0.1
         */
        // Debugging settings
        self.showAlignmentRange = true
        self.showAvoidanceRange = true
        self.showCohesionRange = true
        self.showFleeRange = true
        self.showPredatorOuterRing = true
        self.showPredatorInnerRing = true
        self.showOnlyAlphaBoid = true
        self.showOnlyAlphaPredator = true
        self.showBoidView = true
        self.showArtView = true
        self.showImageView = true
    }
}

class BoidSimulation {
    
    var config: BoidsConfig
    var screenWidth: CGFloat
    var screenHeight: CGFloat
    
    var boids: [BoidNode] = []
    var predators: [BoidNode] = []
    
    init(config: BoidsConfig, screenWidth: CGFloat, screenHeight: CGFloat) {
        self.config = config
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        
        // Anropa funktionen för att skapa boids och predatorer
        let (boids, predators) = createBoidsAndPredators()
        self.boids = boids
        self.predators = predators
    }
    
    // Skapa och returnera boids och predatorer
    func createBoidsAndPredators() -> ([BoidNode], [BoidNode]) {
        var boids: [BoidNode] = []
        var predators: [BoidNode] = []
        
        // Skapa boider
        for _ in 0..<config.numberOfBoids {
            let boidNode = createBoidNode(isPredator: false)
            boidNode.position = randomPosition()
            boids.append(boidNode)
        }
        
        // Skapa predatorer
        for _ in 0..<config.numberOfPredators {
            let predatorNode = createBoidNode(isPredator: true)
            predatorNode.position = randomPosition()
            predators.append(predatorNode)
        }
        
        return (boids, predators)
    }
    
    // Hjälpfunktion för att slumpa positioner på skärmen
    func randomPosition() -> CGPoint {
        let x = CGFloat.random(in: 0...screenWidth)
        let y = CGFloat.random(in: 0...screenHeight)
        return CGPoint(x: x, y: y)
    }
    
    // Skapa en boid- eller predator-nod
    func createBoidNode(isPredator: Bool = false) -> BoidNode {
        let boidNode = BoidNode()
        
        // Skapa triangeln som representerar boiden eller predatorn
        let path = CGMutablePath()
        if isPredator {
            path.move(to: CGPoint(x: 0, y: 10))
            path.addLine(to: CGPoint(x: -6, y: -6))
            path.addLine(to: CGPoint(x: 6, y: -6))
        } else {
            path.move(to: CGPoint(x: 0, y: 5))
            path.addLine(to: CGPoint(x: -3, y: -3))
            path.addLine(to: CGPoint(x: 3, y: -3))
        }
        path.closeSubpath()
        
        // Tilldela boidens path
        boidNode.path = path
        
        // Tilldela färger för fyllning och kant
        boidNode.fillColor = isPredator ? UIColor.red.cgColor : UIColor.white.cgColor
        boidNode.strokeColor = isPredator ? UIColor.white.cgColor : UIColor.red.cgColor
        boidNode.lineWidth = 1.0
        
        // Lägg till perceptionsringar
        if isPredator {
            addPredatorPerceptionRings(to: boidNode)
        } else {
            addBoidPerceptionRings(to: boidNode)
        }
        
        return boidNode
    }
    
    // Lägg till perceptionsringar för predatorer
    private func addPredatorPerceptionRings(to node: BoidNode) {
        print("addPredatorPerceptionRings")
        
        if config.showPredatorOuterRing {
            print("Skapar yttre perceptionsring för predator")
            let outerChaseRing = createRing(radius: config.predatorVisualRange, color: UIColor.systemGreen, name: "outerChaseRing", zPosition: -1)
            node.addSublayer(outerChaseRing)
        }
        
        if config.showPredatorInnerRing {
            print("Skapar inre perceptionsring för predator")
            let innerChaseRing = createRing(radius: config.predatorHuntingRange, color: UIColor.red, name: "innerChaseRing", zPosition: -2)
            node.addSublayer(innerChaseRing)
        }
    }
    
    // Lägg till perceptionsringar för boider
    private func addBoidPerceptionRings(to node: BoidNode) {
        var childrenCount = 0
        if config.showAvoidanceRange {
            let avoidanceRing = createRing(radius: config.avoidanceRange, color: .red, name: "avoidanceRing", zPosition: -1)
            node.addSublayer(avoidanceRing)
            childrenCount += 1
        }
        
        if config.showAlignmentRange {
            let alignmentRing = createRing(radius: config.alignmentRange, color: .cyan, name: "alignmentRing", zPosition: -2)
            node.addSublayer(alignmentRing)
            childrenCount += 1
        }
        
        if config.showCohesionRange {
            let cohesionRing = createRing(radius: config.cohesionRange, color: .green, name: "cohesionRing", zPosition: -3)
            node.addSublayer(cohesionRing)
            childrenCount += 1
        }
        
        if config.showFleeRange {
            let fleeRing = createRing(radius: config.fleeRange, color: .orange, name: "fleeRing", zPosition: -4)
            node.addSublayer(fleeRing)
            childrenCount += 1
        }
        
        print("BoidNode has \(childrenCount) perception rings")
    }
    // Hjälpfunktion för att skapa perceptionsringar
    // Uppdatera funktionen för att skapa ringarna
    private func createRing(radius: CGFloat, color: UIColor, name: String, zPosition: Int) -> CAShapeLayer {
        let ringNode = CAShapeLayer()
        ringNode.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        ringNode.strokeColor = color.cgColor // Ställer in färgen korrekt med CGColor
        ringNode.fillColor = UIColor.clear.cgColor // Ingen fyllnad, endast kantlinje
        ringNode.lineWidth = 1.0 // Gör linjen tydligare
        ringNode.opacity = 0.8 // Gör ringen mer synlig
        ringNode.zPosition = CGFloat(zPosition)
        ringNode.name = name
        
        print("Ring '\(name)' skapad med radie: \(radius), zPosition: \(zPosition)")
        
        return ringNode
    }
    
    
    
    
    
    
    
}
class BoidFlocking {
    var boids: [BoidNode]
    var predators: [BoidNode]
    var screenWidth: CGFloat
    var screenHeight: CGFloat
    var config: BoidsConfig
    
    init(boids: [BoidNode], predators: [BoidNode], screenWidth: CGFloat, screenHeight: CGFloat, config: BoidsConfig) {
        self.boids = boids
        self.predators = predators
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self.config = config
    }
    
    func updateAllBoids() {
        for i in 0..<boids.count {
            updateBoid(boidIndex: i)
        }
    }
    
    func updateAllPredators() {
        for i in 0..<predators.count {
            updatePredator(predatorIndex: i)
        }
    }
    
    func updateBoid(boidIndex: Int) {
        var boid = boids[boidIndex]
        
        // Beräkna styrkrafter
        let alignment = align(boid: boid, boids: boids, alignmentRange: config.alignmentRange)
        let separation = avoid(boid: boid, boids: boids, avoidanceRange: config.avoidanceRange)
        let cohesion = attract(boid: boid, boids: boids, cohesionRange: config.cohesionRange)
        let flee = fleeFromPredator(boid: boid, predators: predators, fleeRange: config.fleeRange)
        
        // Dynamisk driftfaktor baserat på boidens maxhastighet
        let driftFactor = config.driftPercentage * (config.maxSpeed / 10.0)
        let randomDrift = randomSteering() * driftFactor
        
        // Kombinera alla styrkrafter med konfigurerade vikter
        var steering = alignment * config.alignmentFactor +
        separation * config.avoidanceFactor +
        cohesion * config.cohesionFactor +
        randomDrift +
        flee * config.fleeFactor
        
        
        // Check if boid is isolated before applying drift
        if isIsolated(boid: boid, boids: boids, isolationRange: config.alignmentRange) {
            applyDriftIfIsolated(boid: &boid)
        }
        
        // Applicera kantvändningslogik precis innan uppdatering av hastighet och position
        let edgeSteering = turnWhenNearEdges(boid: boid, screenWidth: screenWidth, screenHeight: screenHeight, edgeThreshold: config.edgeThreshold, edgeAvoidanceFactor: config.edgeAvoidanceFactor)
        steering += edgeSteering
        
        
        
        
        // Uppdatera hastighet och position
        boid.velocity += steering
        
        // Begränsa hastigheten till maxhastigheten
        boid.velocity = boid.velocity.normalized() * config.maxSpeed
        
        // Uppdatera positionen genom att konvertera velocity till CGPoint
        boid.position = CGPoint(x: boid.position.x + boid.velocity.x, y: boid.position.y + boid.velocity.y)
        
        // Spara tillbaka den uppdaterade boiden i boids-arrayen
        boids[boidIndex] = boid
    }
    
    func updatePredator(predatorIndex: Int) {
        let predator = predators[predatorIndex]
        
        if let nearestBoid = findNearestBoid(to: predator, within: config.predatorVisualRange) {
            let distance = predator.position.distance(to: nearestBoid.position) // Använder avståndsberäkning
            
            if distance < config.predatorHuntingRange {
                // Aggressiv jakt
                let directionToBoid = (nearestBoid.position - predator.position).normalized() // Använder subtraktion med CGPoint -> Vector3
                predator.velocity = directionToBoid * config.predatorAggressiveSpeed
            } else if distance < config.predatorVisualRange {
                // Börja vända sig mot boiden
                let directionToBoid = (nearestBoid.position - predator.position).normalized()
                predator.velocity += directionToBoid * config.predatorTurnSpeed
                predator.velocity = predator.velocity.normalized() * config.predatorSpeed
            }
        } else {
            // Använd random drift om ingen boid är inom räckhåll
            let randomDrift = randomSteering() * config.predatorDriftFactor
            predator.velocity += randomDrift
            predator.velocity = predator.velocity.normalized() * config.predatorSpeed
        }
        
        // Tillämpa kantvändning
        let edgeSteering = turnWhenNearEdges(boid: predator, screenWidth: screenWidth, screenHeight: screenHeight, edgeThreshold: config.edgeThreshold, edgeAvoidanceFactor: config.edgeAvoidanceFactor)
        predator.velocity += edgeSteering
        
        // Uppdatera positionen genom att lägga till en Vector3 till CGPoint
        predator.position.add(predator.velocity) // Använder add() för att uppdatera positionen
        
        predators[predatorIndex] = predator
    }
    
    // Helper function to determine if a boid is isolated
    func isIsolated(boid: BoidNode, boids: [BoidNode], isolationRange: CGFloat) -> Bool {
        for otherBoid in boids {
            if boid !== otherBoid {
                let distance = boid.position.distance(to: otherBoid.position)
                if distance < isolationRange {
                    return false // Boid is not isolated
                }
            }
        }
        return true // Boid is isolated
    }
    
    
    
    
    
    
    
    
    
    
    func panicEscape(boid: BoidNode, predators: [BoidNode], panicRange: CGFloat, chaseRange: CGFloat) -> Vector3 {
        var steering = Vector3(x: 0, y: 0, z: 0)
        var maxPanicStrength: CGFloat = 0.0
        
        for predator in predators {
            let distance = boid.position.distance(to: predator.position)
            
            if distance < panicRange {
                // Om boiden är i fara (ytterligare flyktområde)
                let avoidDirection = boid.position - predator.position
                let strengthFactor = pow((panicRange - distance) / panicRange, 2)
                
                if strengthFactor > maxPanicStrength {
                    maxPanicStrength = strengthFactor
                    steering = avoidDirection * strengthFactor
                }
            }
            
            if distance < chaseRange {
                // Om boiden är jagad, öka farten och lägg till variation
                let avoidDirection = (boid.position - predator.position).normalized()
                let randomEvasion = randomSteering() * 0.3 // Lägg till lite variation för att simulera manövrar
                steering += (avoidDirection + randomEvasion) * config.panicFlightSpeed
            }
        }
        
        if maxPanicStrength > 0 {
            // Använd panikhastighet för att ge en starkare impuls
            steering = steering.normalized() * (config.maxSpeed * config.panicFlightSpeed)
        }
        
        return steering
    }
    
    
    
    func findNearestBoid(to predator: BoidNode, within range: CGFloat) -> BoidNode? {
        var nearestBoid: BoidNode?
        var shortestDistance = range
        
        for boid in boids {
            let distance = predator.position.distance(to: boid.position)
            if distance < shortestDistance {
                shortestDistance = distance
                nearestBoid = boid
            }
        }
        
        return nearestBoid
    }
    
    func findNearestBoid(to predator: BoidNode) -> BoidNode? {
        var nearestBoid: BoidNode?
        var shortestDistance = CGFloat.greatestFiniteMagnitude
        
        for boid in boids {
            let distance = predator.position.distance(to: boid.position)
            if distance < shortestDistance {
                shortestDistance = distance
                nearestBoid = boid
            }
        }
        
        return nearestBoid
    }
    
    
    func clampVelocity(boid: inout BoidNode, maxSpeed: CGFloat) {
        if boid.velocity.magnitude() > maxSpeed {
            boid.velocity = boid.velocity.normalized() * maxSpeed
        }
    }
    func align(boid: BoidNode, boids: [BoidNode], alignmentRange: CGFloat) -> Vector3 {
        var steering = Vector3(x: 0, y: 0, z: 0)
        var total = 0
        
        for otherBoid in boids {
            let distance = boid.position.distance(to: otherBoid.position)
            if distance < alignmentRange && distance > 0 {
                steering += otherBoid.velocity
                total += 1
            }
        }
        
        if total > 0 {
            steering /= CGFloat(total)
            steering = steering.normalized() * boid.velocity.magnitude()
            steering -= boid.velocity
        }
        
        return steering
    }
    func avoid(boid: BoidNode, boids: [BoidNode], avoidanceRange: CGFloat) -> Vector3 {
        var steering = Vector3(x: 0, y: 0, z: 0)
        var total = 0
        
        for otherBoid in boids {
            let distance = boid.position.distance(to: otherBoid.position)
            if distance < avoidanceRange && distance > 0 {
                let difference = boid.position - otherBoid.position
                steering += difference / distance
                total += 1
            }
        }
        
        if total > 0 {
            steering /= CGFloat(total)
            steering = steering.normalized() * boid.velocity.magnitude()
        }
        
        return steering
    }
    func attract(boid: BoidNode, boids: [BoidNode], cohesionRange: CGFloat) -> Vector3 {
        var centerOfMass = Vector3(x: 0, y: 0, z: 0) // Börjar med ett tomt "center of mass"
        var total = 0
        
        for otherBoid in boids {
            let distance = boid.position.distance(to: otherBoid.position)
            if distance < cohesionRange && distance > 0 {
                // Konvertera otherBoid.position (CGPoint) till Vector3 innan vi adderar
                centerOfMass += Vector3(from: otherBoid.position)
                total += 1
            }
        }
        
        if total > 0 {
            centerOfMass /= CGFloat(total) // Få medelvärdet
            
            // Konvertera boid.position till Vector3 innan subtraktion
            let directionToCenter = centerOfMass - Vector3(from: boid.position)
            return directionToCenter.normalized() * boid.velocity.magnitude() - boid.velocity
        }
        
        return Vector3(x: 0, y: 0, z: 0)
    }
    func randomSteering() -> Vector3 {
        let randomX = CGFloat.random(in: -0.1...0.1)
        let randomY = CGFloat.random(in: -0.1...0.1)
        return Vector3(x: randomX, y: randomY, z: 0).normalized()
    }
    func turnWhenNearEdges(boid: BoidNode, screenWidth: CGFloat, screenHeight: CGFloat, edgeThreshold: CGFloat, edgeAvoidanceFactor: CGFloat) -> Vector3 {
        var steering = Vector3(x: 0, y: 0, z: 0)
        
        // Margin levels för att gradvis öka styrkraften när boiden närmar sig kanten
        let levels: [CGFloat] = [25, 20, 15, 10, 5] // Avståndsnivåer i px
        let angleAdjustments: [CGFloat] = [0.2, 0.4, 0.6, 0.8, 1.0] // Faktor för styrkraftsjustering
        
        // Hjälpfunktion för att beräkna styrkraft baserat på avstånd till kanten
        func calculateSteeringFactor(for distance: CGFloat, isIncreasing: Bool) -> CGFloat {
            for (index, level) in levels.enumerated() {
                if distance < level {
                    let factor = angleAdjustments[index]
                    return isIncreasing ? factor : -factor
                }
            }
            return 0
        }
        
        // Kolla hur nära boiden är vänster eller höger kant
        if boid.position.x < edgeThreshold {
            let distance = boid.position.x
            steering.x += calculateSteeringFactor(for: distance, isIncreasing: true) * edgeAvoidanceFactor
        } else if boid.position.x > screenWidth - edgeThreshold {
            let distance = screenWidth - boid.position.x
            steering.x += calculateSteeringFactor(for: distance, isIncreasing: false) * edgeAvoidanceFactor
        }
        
        // Kolla hur nära boiden är toppen eller botten
        if boid.position.y < edgeThreshold {
            let distance = boid.position.y
            steering.y += calculateSteeringFactor(for: distance, isIncreasing: true) * edgeAvoidanceFactor
        } else if boid.position.y > screenHeight - edgeThreshold {
            let distance = screenHeight - boid.position.y
            steering.y += calculateSteeringFactor(for: distance, isIncreasing: false) * edgeAvoidanceFactor
        }
        
        // Skalera styrningen baserat på boidens hastighet för att få en smidigare vändning
        return steering * boid.velocity.magnitude() * 0.1 // Justera multiplikatorn för att finjustera svängningen
    }
    
    
    func calculateSteeringStrength(distance: CGFloat, outerThreshold: CGFloat, innerThreshold: CGFloat) -> CGFloat {
        if distance > innerThreshold {
            return distance / outerThreshold // Styrkan ökar gradvis från 0 till 1
        } else {
            return 1.0 + ((innerThreshold - distance) / innerThreshold) // Ökar ytterligare utanför innerThreshold
        }
    }
    
    func fleeFromPredator(boid: BoidNode, predators: [BoidNode], fleeRange: CGFloat) -> Vector3 {
        var steering = Vector3(x: 0, y: 0, z: 0)
        var isFleeing = false
        
        for predator in predators {
            let distance = boid.position.distance(to: predator.position)
            if distance < fleeRange {
                // Vänd 180 grader från predatorn
                let difference = (boid.position - predator.position).normalized()
                steering += difference
                isFleeing = true
            }
        }
        
        if isFleeing {
            // Fyrdubbla hastigheten vid flykt
            steering = steering.normalized() * (config.maxSpeed * 4)
        }
        
        return steering
    }
    
    func applyDriftIfIsolated(boid: inout BoidNode) {
        // Drift properties, modify as needed
        let maxSteeringAngle: CGFloat = 15.0  // Max drift angle in degrees
        let driftDurationMax = 10  // Max duration in frames
        let initialDriftChance: CGFloat = 0.1  // Initial chance to start drifting (10%)
        
        // Check if boid is already drifting
        if !boid.isDrifting {
            // Randomly decide if boid should start drifting
            if CGFloat.random(in: 0...1) < initialDriftChance {
                // Initialize drift properties
                boid.isDrifting = true
                boid.driftDirection = Bool.random() ? .left : .right  // Randomly left or right
                boid.driftAngle = CGFloat.random(in: 2...maxSteeringAngle)  // Set initial angle
                boid.driftRemainingFrames = driftDurationMax  // Set drift duration
            }
        } else {
            // Boid is already drifting
            if boid.driftRemainingFrames > 0 {
                // Random chance to continue drifting, decreasing with each step
                let continuationChance = CGFloat(boid.driftRemainingFrames) / CGFloat(driftDurationMax)
                if CGFloat.random(in: 0...1) < continuationChance {
                    // Adjust drift direction with a weighted bias
                    if CGFloat.random(in: 0...1) < 0.6 {
                        // Continue in the same direction
                        boid.driftAngle = min(maxSteeringAngle, boid.driftAngle)
                    } else {
                        // Small chance to change direction
                        boid.driftDirection = boid.driftDirection == .left ? .right : .left
                    }
                    
                    // Apply drift to the boid's current direction
                    let angleChange = boid.driftDirection == .left ? -boid.driftAngle : boid.driftAngle
                    boid.velocity = boid.velocity.rotated(by: angleChange)
                    
                    // Decrease drift angle gradually
                    boid.driftAngle *= 0.9
                    
                    // Decrease remaining frames
                    boid.driftRemainingFrames -= 1
                } else {
                    // Stop drifting
                    boid.isDrifting = false
                }
            } else {
                // Drift duration completed, reset drift properties
                boid.isDrifting = false
            }
        }
    }
    
}
