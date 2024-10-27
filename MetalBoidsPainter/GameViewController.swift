import UIKit
import MetalKit
import Photos

class GameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // "global" variables
    var isSimulationRunning = false // Status för simuleringen
    var simulationTimer: Timer? // Timer för simuleringen
    var boidSimulation: BoidSimulation?
    var boids: [BoidNode] = []
    var predators: [BoidNode] = []
    var isBoidsAndPredatorsAdded = false
    var artViewImage: UIImage? = nil
    var layerCount = 0
    let maxLayerCount = 50 // You can adjust this based on your needs
    var paintedCurvesCount: Int = 0
    
    let brushManager = BrushManager()
    
    
    var backgroundView = UIView()
    var sourceImageView = UIImageView()
    //var artView = UIView()
    var artView: UIImageView = UIImageView()
    var boidsView = UIView()
    var settingsView = UIView()
    var gearButton = UIButton(type: .system)
    var playPauseButton = UIButton(type: .system)
    var saveButton = UIButton(type: .system)
    
    // Inställningsvyns knappar och switchar
    var boidsSwitch = UISwitch()
    var artSwitch = UISwitch()
    var imageSwitch = UISwitch()
    var avoidanceSwitch = UISwitch()
    var alignmentSwitch = UISwitch()
    var cohesionSwitch = UISwitch()
    var fleeSwitch = UISwitch()
    var visualRangeSwitch = UISwitch()
    var huntingRangeSwitch = UISwitch()
    var alphaPredatorSwitch = UISwitch()
    var alphaBoidSwitch = UISwitch()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lägg till vyerna till huvudvyn
        view.addSubview(backgroundView)
        view.addSubview(sourceImageView)
        view.addSubview(artView)
        view.addSubview(boidsView)
        view.addSubview(settingsView)
        
        // Inaktivera translatesAutoresizingMaskIntoConstraints för Auto Layout
        [backgroundView, sourceImageView, artView, boidsView, settingsView].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Konfigurera bakgrundsfärger för att lätt kunna se vyerna
        backgroundView.backgroundColor = .gray
        sourceImageView.backgroundColor = .blue
        artView.backgroundColor = .clear
        boidsView.backgroundColor = .clear
        settingsView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8) // Solid bakgrund
        
        
        
        // Lägg till constraints för att placera alla vyer i fullskärmsläge
        setupFullScreenConstraints()
        
        // buttons
        setupGearButton()
        setupPlayPauseButton()
        setupSaveButton()
        
        
        setupSwitchActions()
        
        // Lägg till inställningsknappar och switchar
        setupSettingsView()
        
        // debug
        tmpDebug(hideSettings: true, hideBackground: true, hideSourceImage: false, hideArt: true, hideBoids: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Säkerställ att boidsView har rätt storlek
        if boidSimulation == nil {
            let config = BoidsConfig(speedFactor: 1.6)
            let screenWidth = boidsView.bounds.width
            let screenHeight = boidsView.bounds.height
            boidSimulation = BoidSimulation(config: config, screenWidth: screenWidth, screenHeight: screenHeight)
        }
        
        // Lägg till boids och predatorer om inte redan gjort
        // Kontrollera om boids och predators redan har lagts till
        if !isBoidsAndPredatorsAdded {
            addBoidAndPredatorToView()
            isBoidsAndPredatorsAdded = true  // Sätt flaggan till true när de har lagts till
            
            syncSwitchesWithConfig()
            
            // Uppdatera synligheten för perceptionsringar baserat på konfigurationen
            toggleRingVisibility(for: "avoidanceRing", isHidden: !boidSimulation!.config.showAvoidanceRange)
            toggleRingVisibility(for: "alignmentRing", isHidden: !boidSimulation!.config.showAlignmentRange)
            toggleRingVisibility(for: "cohesionRing", isHidden: !boidSimulation!.config.showCohesionRange)
            toggleRingVisibility(for: "fleeRing", isHidden: !boidSimulation!.config.showFleeRange)
            toggleRingVisibility(for: "outerChaseRing", isHidden: !boidSimulation!.config.showPredatorOuterRing)
            toggleRingVisibility(for: "innerChaseRing", isHidden: !boidSimulation!.config.showPredatorInnerRing)
            
            toggleViewVisibility(for: "boidView", isHidden: !boidSimulation!.config.showBoidView)
            toggleViewVisibility(for: "artView", isHidden: !boidSimulation!.config.showArtView)
            toggleViewVisibility(for: "imageView", isHidden: !boidSimulation!.config.showImageView)
            
            
        }
        
    }
    func syncSwitchesWithConfig() {
        guard let config = boidSimulation?.config else { return }
        
        avoidanceSwitch.isOn = config.showAvoidanceRange
        alignmentSwitch.isOn = config.showAlignmentRange
        cohesionSwitch.isOn = config.showCohesionRange
        fleeSwitch.isOn = config.showFleeRange
        visualRangeSwitch.isOn = config.showPredatorOuterRing
        huntingRangeSwitch.isOn = config.showPredatorInnerRing
        alphaBoidSwitch.isOn = config.showOnlyAlphaBoid
        alphaPredatorSwitch.isOn = config.showOnlyAlphaPredator
        
        boidsSwitch.isOn = config.showBoidView
        artSwitch.isOn = config.showArtView
        imageSwitch.isOn = config.showImageView
        
        //toggleAllBoidRings(hideAllExceptFirst: hideAll)
    }
    
    
    // Lägg till alla switch-eventhanterare här
    func setupSwitchActions() {
        avoidanceSwitch.addTarget(self, action: #selector(toggleAvoidanceRange), for: .valueChanged)
        alignmentSwitch.addTarget(self, action: #selector(toggleAlignmentRange), for: .valueChanged)
        cohesionSwitch.addTarget(self, action: #selector(toggleCohesionRange), for: .valueChanged)
        fleeSwitch.addTarget(self, action: #selector(toggleFleeRange), for: .valueChanged)
        visualRangeSwitch.addTarget(self, action: #selector(toggleVisualRange), for: .valueChanged)
        huntingRangeSwitch.addTarget(self, action: #selector(toggleHuntingRange), for: .valueChanged)
        alphaBoidSwitch.addTarget(self, action: #selector(toggleAlphaBoid), for: .valueChanged)
        alphaPredatorSwitch.addTarget(self, action: #selector(toggleAlphaPredator), for: .valueChanged)
        
        boidsSwitch.addTarget(self, action: #selector(toggleBoidView), for: .valueChanged)
        artSwitch.addTarget(self, action: #selector(toggleArtView), for: .valueChanged)
        imageSwitch.addTarget(self, action: #selector(toggleImageView), for: .valueChanged)
    }
    
    // Funktionsdefinitioner för varje switch
    
    @objc func toggleBoidView() {
        boidSimulation?.config.showBoidView = boidsSwitch.isOn
        toggleViewVisibility(for: "boidView", isHidden: !boidsSwitch.isOn)
    }
    @objc func toggleArtView() {
        boidSimulation?.config.showArtView = artSwitch.isOn
        toggleViewVisibility(for: "artView", isHidden: !artSwitch.isOn)
    }
    @objc func toggleImageView() {
        boidSimulation?.config.showImageView = imageSwitch.isOn
        toggleViewVisibility(for: "imageView", isHidden: !imageSwitch.isOn)
    }
    
    @objc func toggleAvoidanceRange() {
        boidSimulation?.config.showAvoidanceRange = avoidanceSwitch.isOn
        toggleRingVisibility(for: "avoidanceRing", isHidden: !avoidanceSwitch.isOn)
    }
    
    @objc func toggleAlignmentRange() {
        boidSimulation?.config.showAlignmentRange = alignmentSwitch.isOn
        toggleRingVisibility(for: "alignmentRing", isHidden: !alignmentSwitch.isOn)
    }
    
    @objc func toggleCohesionRange() {
        boidSimulation?.config.showCohesionRange = avoidanceSwitch.isOn
        toggleRingVisibility(for: "cohesionRing", isHidden: !cohesionSwitch.isOn)
    }
    
    @objc func toggleFleeRange() {
        boidSimulation?.config.showFleeRange = fleeSwitch.isOn
        toggleRingVisibility(for: "fleeRing", isHidden: !fleeSwitch.isOn)
    }
    
    @objc func toggleVisualRange() {
        boidSimulation?.config.showPredatorOuterRing = visualRangeSwitch.isOn
        toggleRingVisibility(for: "outerChaseRing", isHidden: !visualRangeSwitch.isOn)
    }
    
    @objc func toggleHuntingRange() {
        boidSimulation?.config.showPredatorInnerRing = huntingRangeSwitch.isOn
        toggleRingVisibility(for: "innerChaseRing", isHidden: !huntingRangeSwitch.isOn)
    }
    
    // AlphaBoid switch - göm alla ringar utom för boid[0]
    @objc func toggleAlphaBoid() {
        let hideAll = !alphaBoidSwitch.isOn
        toggleAllBoidRings(hideAllExceptFirst: hideAll)
    }
    
    // AlphaPredator switch - göm alla ringar utom för predator[0]
    @objc func toggleAlphaPredator() {
        let hideAll = !alphaPredatorSwitch.isOn
        toggleAllPredatorRings(hideAllExceptFirst: hideAll)
    }
    
    func toggleViewVisibility(for viewName: String, isHidden: Bool) {
        switch viewName {
        case "boidView":
            boidsView.isHidden = isHidden
        case "artView":
            artView.isHidden = isHidden
        case "imageView":
            sourceImageView.isHidden = isHidden
        default:
            print("Unknown view: \(viewName)")
        }
    }
    
    // Funktion för att gömma eller visa specifika perceptionsringar
    func toggleRingVisibility(for ringName: String, isHidden: Bool) {
        for boid in boidSimulation?.boids ?? [] {
            boid.sublayers?.forEach { layer in
                if let shapeLayer = layer as? CAShapeLayer, shapeLayer.name == ringName {
                    shapeLayer.isHidden = isHidden
                }
            }
        }
        for predator in boidSimulation?.predators ?? [] {
            predator.sublayers?.forEach { layer in
                if let shapeLayer = layer as? CAShapeLayer, shapeLayer.name == ringName {
                    shapeLayer.isHidden = isHidden
                }
            }
        }
    }
    
    // Funktion för att gömma alla boid-ringar utom för den första
    func toggleAllBoidRings(hideAllExceptFirst: Bool) {
        for (index, boid) in (boidSimulation?.boids ?? []).enumerated() {
            let shouldHide = hideAllExceptFirst && index != 0
            boid.sublayers?.forEach { layer in
                if let shapeLayer = layer as? CAShapeLayer {
                    shapeLayer.isHidden = shouldHide
                }
            }
        }
    }
    
    // Funktion för att gömma alla predator-ringar utom för den första
    func toggleAllPredatorRings(hideAllExceptFirst: Bool) {
        for (index, predator) in (boidSimulation?.predators ?? []).enumerated() {
            let shouldHide = hideAllExceptFirst && index != 0
            predator.sublayers?.forEach { layer in
                if let shapeLayer = layer as? CAShapeLayer {
                    shapeLayer.isHidden = shouldHide
                }
            }
        }
    }
    
    func setupFullScreenConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        // Ställ in fullskärmsconstraints för alla vyer så att de täcker hela skärmen
        [backgroundView, sourceImageView, artView, boidsView, settingsView].forEach { view in
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: safeArea.topAnchor),
                view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
            ])
        }
    }
    
    func setupGearButton() {
        // Skapa en systemknapp med gear-ikonen
        let gearImage = UIImage(systemName: "gearshape.fill")
        gearButton.setImage(gearImage, for: .normal)
        setupButtonAppearance(gearButton)
        
        // Lägg till knappen till huvudvyn
        view.addSubview(gearButton)
        
        // Inaktivera translatesAutoresizingMaskIntoConstraints för Auto Layout
        gearButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Ställ in constraints för att placera den högst upp till höger
        NSLayoutConstraint.activate([
            gearButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            gearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            gearButton.widthAnchor.constraint(equalToConstant: 40),
            gearButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Ställ in zPosition för att alltid vara överst
        view.bringSubviewToFront(gearButton)
        
        // Lägg till klickhändelse för att toggla settings-vyn
        gearButton.addTarget(self, action: #selector(toggleSettingsView), for: .touchUpInside)
    }
    func setupPlayPauseButton() {
        // Skapa en systemknapp med play-ikonen
        let playImage = UIImage(systemName: "play.fill")
        playPauseButton.setImage(playImage, for: .normal)
        setupButtonAppearance(playPauseButton)
        
        // Lägg till knappen till huvudvyn
        view.addSubview(playPauseButton)
        
        // Inaktivera translatesAutoresizingMaskIntoConstraints för Auto Layout
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Ställ in constraints för att placera den bredvid gear-knappen
        NSLayoutConstraint.activate([
            playPauseButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            playPauseButton.trailingAnchor.constraint(equalTo: gearButton.leadingAnchor, constant: -10),
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Lägg till mål för att hantera knapptryckningar
        playPauseButton.addTarget(self, action: #selector(toggleSimulation), for: .touchUpInside)
    }
    func setupSaveButton() {
        // Skapa en systemknapp med play-ikonen
        let saveImage = UIImage(systemName: "square.and.arrow.down")
        saveButton.setImage(saveImage, for: .normal)
        setupButtonAppearance(saveButton)
        
        // Lägg till knappen till huvudvyn
        view.addSubview(saveButton)
        
        // Inaktivera translatesAutoresizingMaskIntoConstraints för Auto Layout
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Ställ in constraints för att placera den bredvid gear-knappen
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -10),
            saveButton.widthAnchor.constraint(equalToConstant: 40),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Lägg till mål för att hantera knapptryckningar
        saveButton.addTarget(self, action: #selector(saveGeneratedImage), for: .touchUpInside)
    }
    func setupButtonAppearance(_ button: UIButton) {
        button.tintColor = UIColor.white // Change icon color to red
        button.layer.borderWidth = 2.0 // Width of the border
        button.backgroundColor = UIColor.white.withAlphaComponent(0.5) // Set button background color with 50% opacity
        button.layer.borderColor = UIColor.white.cgColor // Border color, you can adjust it as needed
        button.layer.cornerRadius = 10.0 // To make the edges rounded, adjust radius as needed
        button.layer.masksToBounds = true // Ensures the rounded corners are applied
    }
    @objc func saveGeneratedImage() {
        // Capture the artView as an image
        if let image = captureArtViewAsImage() {
            // Save the image to the photo library
            saveImageToPhotoLibrary(image)
        } else {
            print("Failed to capture artView as image.")
        }
    }

    // Capture artView as an image
    func captureArtViewAsImage() -> UIImage? {
        // Ensure the view has a valid size
        let renderer = UIGraphicsImageRenderer(size: artView.bounds.size)
        
        // Capture the view as an image
        let image = renderer.image { context in
            artView.drawHierarchy(in: artView.bounds, afterScreenUpdates: true)
        }
        
        return image
    }

    // Save the captured image to the photo library
    func saveImageToPhotoLibrary(_ image: UIImage) {
        // Ask for permission and save the image to the photo library
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            if success {
                print("Image successfully saved to the photo library!")
            } else if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            }
        })
    }
    // Starta eller stoppa simuleringen när play/paus-knappen trycks
    @objc func toggleSimulation() {
        if isSimulationRunning {
            pauseSimulation()
        } else {
            startSimulation()
        }
    }
    
    func startSimulation() {
        // Ändra till paus-ikon
        let pauseImage = UIImage(systemName: "pause.fill")
        playPauseButton.setImage(pauseImage, for: .normal)
        
        // Starta timern med 1-sekundsintervall
        simulationTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(simulationTick), userInfo: nil, repeats: true)
        
        isSimulationRunning = true
    }
    
    func pauseSimulation() {
        // Ändra till play-ikon
        let playImage = UIImage(systemName: "play.fill")
        playPauseButton.setImage(playImage, for: .normal)
        
        // Stoppa timern
        simulationTimer?.invalidate()
        simulationTimer = nil
        
        isSimulationRunning = false
    }
    func resetSimulation() {
        // 1. Stop the simulation
        simulationTimer?.invalidate()
        simulationTimer = nil
        isSimulationRunning = false

        // 2. Clear all layers and uploaded images
        artView.image = nil
        sourceImageView.image = nil
        boidsView.layer.sublayers?.removeAll()
        
        // 3. Reset configuration to default values
        let config = BoidsConfig() // Initializes with default values
        boidSimulation = BoidSimulation(config: config, screenWidth: view.bounds.width, screenHeight: view.bounds.height)
        
        // 4. Reinitialize boids and predators with the updated config
        let (boids, predators) = boidSimulation!.createBoidsAndPredators()
        self.boids = boids
        self.predators = predators
        
        // 5. Add boids and predators to the view if necessary
        addBoidAndPredatorToView()
        
        print("Simulation reset complete.")
    }
    
    @objc func simulationTick() {
        // Kontrollera om en uppdatering redan körs
        //guard !isSimulationRunning else {
        //    return // Om den redan körs, returnera och vänta på nästa tick
        //}
        
        //isSimulationRunning = true // Blockera nya anrop tills denna är klar
        
        // Kör simuleringen
        runSimulation()
        
        //isSimulationRunning = false // När simuleringen är klar, släpp flaggan
    }
    
    // Huvudfunktion som kör simuleringen
    func runSimulation() {
        // Säkerställ att boidSimulation finns
        guard let boidSimulation = boidSimulation else {
            print("BoidSimulation saknas.")
            return
        }
        
        // Ladda den uppladdade bilden från din imageView
        guard let sourceImage = sourceImageView.image else {
            print("Ingen uppladdad bild.")
            return
        }
        
        
        // Skapa BoidFlocking och uppdatera boids och predatorer
        let boidFlocking = BoidFlocking(boids: boidSimulation.boids,
                                        predators: boidSimulation.predators,
                                        screenWidth: boidsView.bounds.width,
                                        screenHeight: boidsView.bounds.height,
                                        config: boidSimulation.config)
        
        boidFlocking.updateAllBoids()
        boidFlocking.updateAllPredators()
        
        //clearArtView()
        
        // Uppdatera visuella representationer för boids
        for (index, boid) in boidSimulation.boids.enumerated() {
            if let boidNode = boidsView.layer.sublayers?[index] as? BoidNode {
                // Uppdatera boidens position
                boidNode.position = CGPoint(x: boid.position.x, y: boid.position.y)
                
                // Hämta färgen från den uppladdade bilden på boidens position
                let positionColor = getPixelColor(at: boidNode.position, in: sourceImage) ?? .clear
                //print(positionColor)
                
                // Lägg till positionen och färgen i historiken
                boidNode.addHistoricPosition(boidNode.position, color: positionColor, maxHistoricPositions: boidSimulation.config.maxHistoricPositions)
                
                if boid.historicPositions.count > 4 {
                    boid.historicPositions.removeFirst()
                }
                drawBoidTail(for: boid, on: artView)
                
                // Räkna ut rotation baserat på hastighet
                let angle = atan2(boid.velocity.y, boid.velocity.x) - CGFloat.pi / 2
                boidNode.setAffineTransform(CGAffineTransform(rotationAngle: angle))
            }
        }
        
        // Uppdatera predatorerna på samma sätt
        let predatorStartIndex = boidSimulation.boids.count
        for (index, predator) in boidSimulation.predators.enumerated() {
            if let predatorNode = boidsView.layer.sublayers?[predatorStartIndex + index] as? CAShapeLayer {
                // Uppdatera predatorns position
                predatorNode.position = CGPoint(x: predator.position.x, y: predator.position.y)
                
                // Räkna ut rotation baserat på hastighet
                let angle = atan2(predator.velocity.y, predator.velocity.x) - CGFloat.pi / 2
                predatorNode.setAffineTransform(CGAffineTransform(rotationAngle: angle))
            }
        }
        //print(boidSimulation.boids[0].historicPositions)
        //print("Boids and predators updated")
    }
    
    func setupSettingsView() {
        // Lägg till komponenter i settingsView
        let imageUploadLabel = createLabel(withText: "Image upload:")
        imageUploadLabel.textColor = .black
        imageUploadLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        imageUploadLabel.textAlignment = .left
        
        
        let browseButton = createButton(withTitle: "Browse")
        browseButton.tintColor = .black
        browseButton.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        browseButton.contentHorizontalAlignment = .right
        browseButton.addTarget(self, action: #selector(browseButtonTapped), for: .touchUpInside)
        
        let layerVisibilityLabel = createLabel(withText: "Layer visibility")
        layerVisibilityLabel.textColor = .black
        layerVisibilityLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        layerVisibilityLabel.textAlignment = .left
        
        let boidsLabel = createLabel(withText: "Boids")
        boidsLabel.textColor = .black
        boidsLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        boidsLabel.textAlignment = .left
        
        let artLabel = createLabel(withText: "Art")
        artLabel.textColor = .black
        artLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        artLabel.textAlignment = .center
        
        let imageLabel = createLabel(withText: "Image")
        imageLabel.textColor = .black
        imageLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        imageLabel.textAlignment = .right
        
        boidsSwitch.translatesAutoresizingMaskIntoConstraints = false
        artSwitch.translatesAutoresizingMaskIntoConstraints = false
        imageSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        avoidanceSwitch.translatesAutoresizingMaskIntoConstraints = false
        alignmentSwitch.translatesAutoresizingMaskIntoConstraints = false
        cohesionSwitch.translatesAutoresizingMaskIntoConstraints = false
        fleeSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        visualRangeSwitch.translatesAutoresizingMaskIntoConstraints = false
        huntingRangeSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        alphaBoidSwitch.translatesAutoresizingMaskIntoConstraints = false
        alphaPredatorSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        
        let perceptionRingsLabel = createLabel(withText: "Perception rings visibility")
        perceptionRingsLabel.textColor = .black
        perceptionRingsLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        perceptionRingsLabel.textAlignment = .center
        
        let perceptionBoidsLabel = createLabel(withText: "Boids")
        perceptionBoidsLabel.textColor = .black
        perceptionBoidsLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        perceptionBoidsLabel.textAlignment = .left
        
        let perceptionPredatorsLabel = createLabel(withText: "Predators")
        perceptionPredatorsLabel.textColor = .black
        perceptionPredatorsLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        perceptionPredatorsLabel.textAlignment = .right
        
        
        let avoidanceLabel = createLabel(withText: "Avoidance")
        avoidanceLabel.textColor = .black
        avoidanceLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        avoidanceLabel.textAlignment = .left
        let alignmentLabel = createLabel(withText: "Alignment")
        alignmentLabel.textColor = .black
        alignmentLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        alignmentLabel.textAlignment = .left
        let cohesionLabel = createLabel(withText: "Cohesion")
        cohesionLabel.textColor = .black
        cohesionLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        cohesionLabel.textAlignment = .left
        let fleeLabel = createLabel(withText: "Flee")
        fleeLabel.textColor = .black
        fleeLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        fleeLabel.textAlignment = .left
        
        let visualRangeLabel = createLabel(withText: "Visual range")
        visualRangeLabel.textColor = .black
        visualRangeLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        visualRangeLabel.textAlignment = .right
        let huntingRangeLabel = createLabel(withText: "Hunting range")
        huntingRangeLabel.textColor = .black
        huntingRangeLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        huntingRangeLabel.textAlignment = .right
        
        let alphaBoidLabel = createLabel(withText: "Alpha boid")
        alphaBoidLabel.textColor = .black
        alphaBoidLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        alphaBoidLabel.textAlignment = .left
        let alphaPredatorLabel = createLabel(withText: "Alpha predator")
        alphaPredatorLabel.textColor = .black
        alphaPredatorLabel.backgroundColor = .clear // Lägg till en bakgrundsfärg så att den blir synlig
        alphaPredatorLabel.textAlignment = .right
        
        // Lägg till alla element till settingsView
        settingsView.addSubview(imageUploadLabel)
        settingsView.addSubview(browseButton)
        settingsView.addSubview(layerVisibilityLabel)
        settingsView.addSubview(boidsLabel)
        settingsView.addSubview(artLabel)
        settingsView.addSubview(imageLabel)
        settingsView.addSubview(boidsSwitch)
        settingsView.addSubview(artSwitch)
        settingsView.addSubview(imageSwitch)
        settingsView.addSubview(perceptionRingsLabel)
        settingsView.addSubview(perceptionBoidsLabel)
        settingsView.addSubview(perceptionPredatorsLabel)
        
        
        
        
        settingsView.addSubview(avoidanceLabel)
        settingsView.addSubview(avoidanceSwitch)
        settingsView.addSubview(alignmentLabel)
        settingsView.addSubview(alignmentSwitch)
        settingsView.addSubview(cohesionLabel)
        settingsView.addSubview(cohesionSwitch)
        settingsView.addSubview(fleeLabel)
        settingsView.addSubview(fleeSwitch)
        //settingsView.addSubview(predatorsSwitch)
        settingsView.addSubview(visualRangeLabel)
        settingsView.addSubview(visualRangeSwitch)
        settingsView.addSubview(huntingRangeLabel)
        settingsView.addSubview(huntingRangeSwitch)
        settingsView.addSubview(alphaBoidLabel)
        settingsView.addSubview(alphaBoidSwitch)
        settingsView.addSubview(alphaPredatorLabel)
        settingsView.addSubview(alphaPredatorSwitch)
        
        
        
        
        // Layout för komponenterna i settingsView (med Auto Layout)
        let verticalPadding: CGFloat = 50
        let padding: CGFloat = 10
        NSLayoutConstraint.activate([
            imageUploadLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: verticalPadding),
            imageUploadLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            imageUploadLabel.heightAnchor.constraint(equalToConstant: 30), // Se till att den har en höjd
            imageUploadLabel.widthAnchor.constraint(equalToConstant: 150), // Se till att den har en bredd
            
            
            browseButton.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: verticalPadding),
            browseButton.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -padding),
            browseButton.heightAnchor.constraint(equalToConstant: 30), // Se till att den har en höjd
            browseButton.widthAnchor.constraint(equalToConstant: 150),
            
            layerVisibilityLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: verticalPadding * 2),
            layerVisibilityLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            layerVisibilityLabel.heightAnchor.constraint(equalToConstant: 30), // Se till att den har en höjd
            layerVisibilityLabel.widthAnchor.constraint(equalToConstant: 150), // Se till att den har en bredd
            
            
            boidsLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: verticalPadding * 3),
            boidsLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            boidsLabel.heightAnchor.constraint(equalToConstant: 30), // Höjd på labeln
            boidsLabel.widthAnchor.constraint(equalToConstant: 80), // Bredd på labeln
            
            // artLabel: Centreras horisontellt, under boidsLabel
            artLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: verticalPadding * 3), // Under boidsLabel
            artLabel.centerXAnchor.constraint(equalTo: settingsView.centerXAnchor), // Centreras horisontellt
            artLabel.heightAnchor.constraint(equalToConstant: 30), // Höjd på labeln
            artLabel.widthAnchor.constraint(equalToConstant: 40), // Bredd på labeln
            
            // imageLabel: Till höger, under artLabel
            imageLabel.topAnchor.constraint(equalTo: settingsView.topAnchor, constant: verticalPadding * 3), // Under artLabel
            imageLabel.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -padding), // Högerjusterad
            imageLabel.heightAnchor.constraint(equalToConstant: 30), // Höjd på labeln
            imageLabel.widthAnchor.constraint(equalToConstant: 80), // Bredd på labeln
            
            boidsSwitch.topAnchor.constraint(equalTo: boidsLabel.bottomAnchor, constant: 10), // Placera switchen under boidsLabel
            boidsSwitch.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            boidsSwitch.trailingAnchor.constraint(lessThanOrEqualTo: settingsView.trailingAnchor, constant: -padding), // Se till att den inte går utanför
            
            
            artSwitch.topAnchor.constraint(equalTo: artLabel.bottomAnchor, constant: 10), // Placera switchen 10 punkter under artLabel
            artSwitch.centerXAnchor.constraint(equalTo: artLabel.centerXAnchor), // Centrera artSwitch horisontellt under artLabel
            
            imageSwitch.topAnchor.constraint(equalTo: imageLabel.bottomAnchor, constant: 10), // Placera switchen 10 punkter under imageLabel
            imageSwitch.trailingAnchor.constraint(equalTo: imageLabel.trailingAnchor), // Högerjustera imageSwitch under imageLabel
            
            perceptionRingsLabel.topAnchor.constraint(equalTo: boidsSwitch.bottomAnchor, constant: 10), // Placera 10 punkter under boidsSwitch
            perceptionRingsLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding), // Vänsterjustera perceptionRingsLabel
            perceptionRingsLabel.heightAnchor.constraint(equalToConstant: 30),
            perceptionRingsLabel.widthAnchor.constraint(equalToConstant: 200),
            
            // PerceptionBoidsLabel (vänsterjusterad, under perceptionRingsLabel)
            perceptionBoidsLabel.topAnchor.constraint(equalTo: perceptionRingsLabel.bottomAnchor, constant: 10), // Placera under perceptionRingsLabel
            perceptionBoidsLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding), // Vänsterjusterad
            perceptionBoidsLabel.heightAnchor.constraint(equalToConstant: 30),
            perceptionBoidsLabel.widthAnchor.constraint(equalToConstant: 150),
            
            // PerceptionPredatorsLabel (högerjusterad, på samma nivå som perceptionBoidsLabel)
            perceptionPredatorsLabel.topAnchor.constraint(equalTo: perceptionBoidsLabel.topAnchor), // Samma nivå som perceptionBoidsLabel
            perceptionPredatorsLabel.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -padding), // Högerjusterad
            perceptionPredatorsLabel.heightAnchor.constraint(equalToConstant: 30),
            perceptionPredatorsLabel.widthAnchor.constraint(equalToConstant: 150),
            
            
            
            
            // Vänsterjusterad, under perceptionBoidsLabel
            avoidanceLabel.topAnchor.constraint(equalTo: perceptionBoidsLabel.bottomAnchor, constant: 10),
            avoidanceLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            avoidanceLabel.heightAnchor.constraint(equalToConstant: 30),
            avoidanceLabel.widthAnchor.constraint(equalToConstant: 110),
            
            avoidanceSwitch.centerYAnchor.constraint(equalTo: avoidanceLabel.centerYAnchor),
            avoidanceSwitch.leadingAnchor.constraint(equalTo: avoidanceLabel.trailingAnchor, constant: 10),
            
            // Alignment
            alignmentLabel.topAnchor.constraint(equalTo: avoidanceLabel.bottomAnchor, constant: 10),
            alignmentLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            alignmentLabel.heightAnchor.constraint(equalToConstant: 30),
            alignmentLabel.widthAnchor.constraint(equalToConstant: 110),
            
            alignmentSwitch.centerYAnchor.constraint(equalTo: alignmentLabel.centerYAnchor),
            alignmentSwitch.leadingAnchor.constraint(equalTo: alignmentLabel.trailingAnchor, constant: 10),
            
            // Cohesion
            cohesionLabel.topAnchor.constraint(equalTo: alignmentLabel.bottomAnchor, constant: 10),
            cohesionLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            cohesionLabel.heightAnchor.constraint(equalToConstant: 30),
            cohesionLabel.widthAnchor.constraint(equalToConstant: 110),
            
            cohesionSwitch.centerYAnchor.constraint(equalTo: cohesionLabel.centerYAnchor),
            cohesionSwitch.leadingAnchor.constraint(equalTo: cohesionLabel.trailingAnchor, constant: 10),
            
            // Flee
            fleeLabel.topAnchor.constraint(equalTo: cohesionLabel.bottomAnchor, constant: 10),
            fleeLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            fleeLabel.heightAnchor.constraint(equalToConstant: 30),
            fleeLabel.widthAnchor.constraint(equalToConstant: 110),
            
            fleeSwitch.centerYAnchor.constraint(equalTo: fleeLabel.centerYAnchor),
            fleeSwitch.leadingAnchor.constraint(equalTo: fleeLabel.trailingAnchor, constant: 10),
            
            visualRangeSwitch.topAnchor.constraint(equalTo: perceptionPredatorsLabel.bottomAnchor, constant: 10),
            visualRangeSwitch.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -padding), // Switch längst till höger
            
            visualRangeLabel.centerYAnchor.constraint(equalTo: visualRangeSwitch.centerYAnchor),
            visualRangeLabel.trailingAnchor.constraint(equalTo: visualRangeSwitch.leadingAnchor, constant: -10), // Label till vänster om switch
            visualRangeLabel.heightAnchor.constraint(equalToConstant: 30),
            visualRangeLabel.widthAnchor.constraint(equalToConstant: 110),
            
            // Hunting Range (Predator) - switch till vänster, label till höger
            huntingRangeSwitch.topAnchor.constraint(equalTo: visualRangeSwitch.bottomAnchor, constant: 10),
            huntingRangeSwitch.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -padding), // Switch längst till höger
            
            huntingRangeLabel.centerYAnchor.constraint(equalTo: huntingRangeSwitch.centerYAnchor),
            huntingRangeLabel.trailingAnchor.constraint(equalTo: huntingRangeSwitch.leadingAnchor, constant: -10), // Label till vänster om switch
            huntingRangeLabel.heightAnchor.constraint(equalToConstant: 30),
            huntingRangeLabel.widthAnchor.constraint(equalToConstant: 110),
            
            
            // Alpha Boid - boids-sidan (vänsterställd under flee)
            alphaBoidLabel.topAnchor.constraint(equalTo: fleeSwitch.bottomAnchor, constant: 10),
            alphaBoidLabel.leadingAnchor.constraint(equalTo: settingsView.leadingAnchor, constant: padding),
            alphaBoidLabel.heightAnchor.constraint(equalToConstant: 30),
            alphaBoidLabel.widthAnchor.constraint(equalToConstant: 110),
            
            alphaBoidSwitch.centerYAnchor.constraint(equalTo: alphaBoidLabel.centerYAnchor),
            alphaBoidSwitch.leadingAnchor.constraint(equalTo: alphaBoidLabel.trailingAnchor, constant: 10),
            
            // Alpha Predator - predatorsidan (högerställd, hoppar över två nivåer)
            alphaPredatorSwitch.topAnchor.constraint(equalTo: huntingRangeSwitch.bottomAnchor, constant: 88), // Hoppar över två nivåer från Hunting Range
            alphaPredatorSwitch.trailingAnchor.constraint(equalTo: settingsView.trailingAnchor, constant: -padding),
            
            alphaPredatorLabel.centerYAnchor.constraint(equalTo: alphaPredatorSwitch.centerYAnchor),
            alphaPredatorLabel.trailingAnchor.constraint(equalTo: alphaPredatorSwitch.leadingAnchor, constant: -10),
            alphaPredatorLabel.heightAnchor.constraint(equalToConstant: 30),
            alphaPredatorLabel.widthAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    // Funktion för att skapa labels
    func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    // Funktion för att skapa knappar
    func createButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func toggleSettingsView() {
        // Toggla settingsView synlighet
        settingsView.isHidden.toggle()
        // Se till att knappen alltid är ovanpå
        view.bringSubviewToFront(gearButton)
    }
    
    func addBoidAndPredatorToView() {
        // Säkerställ att boidSimulation existerar
        guard let boidSimulation = boidSimulation else {
            print("BoidSimulation är inte initialiserad.")
            return
        }
        
        // Lägg till boids i boidsView
        for boidNode in boidSimulation.boids {
            boidsView.layer.addSublayer(boidNode) // Lägg till boid på boidsView
        }
        
        // Lägg till predatorer i boidsView
        for predatorNode in boidSimulation.predators {
            boidsView.layer.addSublayer(predatorNode) // Lägg till predator på boidsView
        }
        
        print("Boids and predators added with random positions.")
    }
    
    func addBoidNodeToView(_ boidNode: BoidNode) {
        // Skapa en CAShapeLayer för boidens path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = boidNode.path
        shapeLayer.fillColor = boidNode.fillColor
        shapeLayer.strokeColor = boidNode.strokeColor
        shapeLayer.lineWidth = boidNode.lineWidth
        shapeLayer.opacity = Float(boidNode.alpha)
        shapeLayer.position = boidNode.position
        shapeLayer.zPosition = boidNode.zPosition
        
        // Lägg till alla barnnoder (t.ex. perceptionsringar)
        for child in boidNode.children {
            addBoidNodeToView(child)
        }
        
        // Lägg till boiden till boidsView
        boidsView.layer.addSublayer(shapeLayer)
    }
    
    func createPerceptionRing(radius: CGFloat, color: UIColor) -> CAShapeLayer {
        let ringLayer = CAShapeLayer()
        let ringPath = UIBezierPath(arcCenter: CGPoint.zero, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        ringLayer.path = ringPath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = color.cgColor
        ringLayer.lineWidth = 1
        ringLayer.opacity = 0.5
        return ringLayer
    }
    
    func tmpDebug(hideSettings: Bool = false, hideBackground: Bool = false, hideSourceImage: Bool = false, hideArt: Bool = false, hideBoids: Bool = false) {
        // Visa eller göm de olika lagren beroende på de boolska värdena
        settingsView.isHidden = hideSettings
        backgroundView.isHidden = hideBackground
        sourceImageView.isHidden = hideSourceImage
        artView.isHidden = hideArt
        boidsView.isHidden = hideBoids
    }
    
    @objc func browseButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func convertToSRGB(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: cgImage.bytesPerRow,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        guard let newCGImage = context?.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Går in i imagePickerController")
        
        if let image = info[.originalImage] as? UIImage {
            // Step 1: Convert to sRGB
            let srgbImage = convertToSRGB(image) ?? image
            if srgbImage === image {
                print("convertToSRGB misslyckades, använder originalbilden.")
            }
            
            // Step 2: Flip the image vertically
            let flippedImage = flipImageVertically(srgbImage) ?? srgbImage
            if flippedImage === srgbImage {
                print("flipImageVertically misslyckades, använder sRGB-bilden.")
            }

            // Step 3: Resize and crop the image to fit in the safe area while preserving aspect ratio
            let targetSize = view.safeAreaLayoutGuide.layoutFrame.size
            if let resizedImage = resizeAndCropImage(flippedImage, toFitIn: targetSize) {
                // Display the final image in sourceImageView
                sourceImageView.image = resizedImage
            }
            // 4 fill background
            if let avgColor = getAverageColor(of: image) {
                setImageCanvasBackgroundColor(to: avgColor)
            }

        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController_old(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Går in i imagePickerController")
        if let image = info[.originalImage] as? UIImage {
            // Konvertera till sRGB först
            let srgbImage = convertToSRGB(image) ?? image
            if srgbImage === image {
                print("convertToSRGB misslyckades, använder originalbilden.")
            }

            // Flippa bilden vertikalt
            let flippedImage = flipImageVertically(srgbImage) ?? srgbImage
            if flippedImage === srgbImage {
                print("flipImageVertically misslyckades, använder sRGB-bilden.")
            }

            // Visa den i sourceImageView
            sourceImageView.image = flippedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func resizeAndCropImage(_ image: UIImage, toFitIn targetSize: CGSize) -> UIImage? {
        // Calculate the aspect ratios
        let imageAspectRatio = image.size.width / image.size.height
        let targetAspectRatio = targetSize.width / targetSize.height

        // Determine the scaling factor that preserves the aspect ratio
        var scaleFactor: CGFloat
        if imageAspectRatio > targetAspectRatio {
            // Image is wider than target area, scale by height
            scaleFactor = targetSize.height / image.size.height
        } else {
            // Image is taller than target area, scale by width
            scaleFactor = targetSize.width / image.size.width
        }

        // Calculate the new size after scaling
        let scaledImageSize = CGSize(width: image.size.width * scaleFactor, height: image.size.height * scaleFactor)

        // Create a new image context with target size
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)

        // Calculate the position to center the image
        let xOffset = (targetSize.width - scaledImageSize.width) / 2
        let yOffset = (targetSize.height - scaledImageSize.height) / 2

        // Draw the scaled image centered in the target area
        image.draw(in: CGRect(x: xOffset, y: yOffset, width: scaledImageSize.width, height: scaledImageSize.height))

        // Get the resulting image
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }
    func getPixelColor(at point: CGPoint, in image: UIImage) -> UIColor? {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        defer { pixelData.deallocate() }

        let context = CGContext(
            data: pixelData,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        // Calculate scaled coordinates
        let xScale = sourceImageView.bounds.width / image.size.width
        let yScale = sourceImageView.bounds.height / image.size.height
        let scaledX = Int(point.x / xScale)
        let scaledY = Int(point.y / yScale)

        // Invert y-coordinate to match image coordinate system
        let adjustedY = image.size.height - CGFloat(scaledY)

        context?.translateBy(x: -CGFloat(scaledX), y: -adjustedY)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        let r = CGFloat(pixelData[0]) / 255.0
        let g = CGFloat(pixelData[1]) / 255.0
        let b = CGFloat(pixelData[2]) / 255.0
        let a = CGFloat(pixelData[3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    func getPixelColor_old(at point: CGPoint, in image: UIImage) -> UIColor? {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        defer { pixelData.deallocate() }

        let context = CGContext(
            data: pixelData,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        let imageSize = image.size

        // Anpassa för spegelvänd bild: invert y-koordinaten
        let flippedY = Int(imageSize.height - point.y)

        let x = Int(point.x)
        let y = flippedY

        context?.translateBy(x: -CGFloat(x), y: -CGFloat(y))
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        let r = CGFloat(pixelData[0]) / 255.0
        let g = CGFloat(pixelData[1]) / 255.0
        let b = CGFloat(pixelData[2]) / 255.0
        let a = CGFloat(pixelData[3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func flipImageVertically(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let size = image.size
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Kontrollera transformationsordningen
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Rita bilden i den spegelvända kontexten
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage
    }
    func flipImageVerticallyCG(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let size = image.size
        let colorSpace = cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: cgImage.bitsPerComponent,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let flippedCgImage = context?.makeImage() else { return nil }
        
        return UIImage(cgImage: flippedCgImage)
    }
    
    /*func drawBoidTail(for boid: BoidNode, on canvas: UIView) {
        guard boid.historicPositions.count >= 4 else { return }

        // Get the last 4 positions
        let latestPositions = Array(boid.historicPositions.suffix(4))
        
        // Extract positions and colors
        let points = latestPositions.map { $0.position }
        let colors = latestPositions.map { $0.color }
        
        // Calculate the average color
        let avgColor = averageColor(from: colors)
        
        // Create a bezier path
        let bezierPath = UIBezierPath()
        bezierPath.move(to: points[0])
        bezierPath.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])

        // Draw the curve on the artView
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeColor = avgColor.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.fillColor = nil

        canvas.layer.addSublayer(shapeLayer)
    }*/



    func drawBoidTail(for boid: BoidNode, on canvas: UIImageView) {
        paintedCurvesCount += 1
        guard boid.historicPositions.count >= 4 else { return }
        
        let brush = brushManager.getBrush(for: Float(paintedCurvesCount))
        
        // Get the last 4 positions
        let latestPositions = Array(boid.historicPositions.suffix(4))
        
        // Extract positions and colors
        let points = latestPositions.map { $0.position }
        let colors = latestPositions.map { $0.color }
        
        // Calculate the average color
        let avgColor = averageColor(from: colors)
        
        // Create the bezier path
        let bezierPath = UIBezierPath()
        bezierPath.move(to: points[0])
        bezierPath.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
        
        // Add the shape layer to the canvas
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.strokeColor = avgColor.cgColor
        shapeLayer.opacity = Float(brush.opacity)
        shapeLayer.lineWidth = brush.strokeSize
        shapeLayer.fillColor = nil
        
        // Add the new layer
        canvas.layer.addSublayer(shapeLayer)
        layerCount += 1

        // If the layer count exceeds the threshold, merge them into one image
        if layerCount >= maxLayerCount {
            mergeLayers(on: canvas)
            layerCount = 0 // Reset the count after merging
        }
    }
    func mergeLayers(on canvas: UIImageView) {
        print(paintedCurvesCount)
        // Create a new image context the size of the canvas
        UIGraphicsBeginImageContextWithOptions(canvas.bounds.size, false, 0)
        
        // Draw the current image (if there is one) on the context
        canvas.image?.draw(in: canvas.bounds)
        
        // Iterate over all layers and render them into the image context
        guard let layers = canvas.layer.sublayers else { return }
        for layer in layers {
            if let shapeLayer = layer as? CAShapeLayer, let path = shapeLayer.path {
                // Render the path in the context
                let context = UIGraphicsGetCurrentContext()
                context?.addPath(path)
                context?.setStrokeColor(shapeLayer.strokeColor ?? UIColor.clear.cgColor)
                context?.setAlpha(CGFloat(shapeLayer.opacity))
                context?.setLineWidth(shapeLayer.lineWidth)
                context?.strokePath()
            }
        }
        
        // Get the final image and set it as the canvas image
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set the merged image and clear all the old layers
        canvas.image = mergedImage
        canvas.layer.sublayers?.removeAll() // Clear all layers after merging
    }
    // Function to compute average color
    func averageColor(from colors: [UIColor]) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        for color in colors {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)

            red += r
            green += g
            blue += b
            alpha += a
        }

        let count = CGFloat(colors.count)
        return UIColor(red: red / count, green: green / count, blue: blue / count, alpha: alpha / count)
    }
    func clearArtView() {
        // Removes all sublayers from the artView
        print("clearArtView")
        if let sublayers = artView.layer.sublayers {
            print(artView.layer.sublayers?.count)
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
    }
    func setImageCanvasBackgroundColor(to color: UIColor) {
        //artView.backgroundColor = color
    }
    func getAverageColor(of image: UIImage) -> UIColor? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = 1
        let height = 1
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var pixelData = [UInt8](repeating: 0, count: 4)
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        // Draw the image in the 1x1 pixel context
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let red = CGFloat(pixelData[0]) / 255.0
        let green = CGFloat(pixelData[1]) / 255.0
        let blue = CGFloat(pixelData[2]) / 255.0
        let alpha = CGFloat(pixelData[3]) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
    
    
}
