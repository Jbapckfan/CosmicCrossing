import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    private var player: Player!
    private var orbitingObjects: [OrbitingObject] = []
    private var lastUpdateTime: TimeInterval = 0

    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var shotsLabel: SKLabelNode!

    private var currentLevel: Int = 1
    private var targetY: CGFloat = 0

    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupHUD()
        createLevel(currentLevel)
    }

    private func setupScene() {
        backgroundColor = SKColor(red: 0.02, green: 0.02, blue: 0.08, alpha: 1.0)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Add beautiful nebula background
        let background = SKSpriteNode(imageNamed: "BackgroundNebula")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -100
        background.alpha = 0.6
        addChild(background)

        // Add starfield background
        createStarfield()
    }

    private func createStarfield() {
        // Create multiple layers of stars for parallax effect
        for layer in 0..<3 {
            let starsNode = SKNode()
            starsNode.name = "starfield_\(layer)"
            starsNode.zPosition = -10 - CGFloat(layer)

            for _ in 0..<100 {
                let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2.0))
                star.fillColor = .white
                star.strokeColor = .clear
                star.alpha = CGFloat.random(in: 0.3...0.8)
                star.position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                )

                // Twinkle animation
                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1.0...3.0)),
                    SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 1.0...3.0))
                ])
                star.run(SKAction.repeatForever(twinkle))

                starsNode.addChild(star)
            }

            addChild(starsNode)
        }
    }

    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: size.width / 2, y: 100)
        player.zPosition = 10
        addChild(player)
    }

    private func setupHUD() {
        // Score label with shadow
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 26
        scoreLabel.position = CGPoint(x: 20, y: size.height - 50)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 100
        scoreLabel.fontColor = .white
        scoreLabel.text = "Score: 0"

        // Add shadow
        let scoreShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreShadow.fontSize = 26
        scoreShadow.fontColor = .black
        scoreShadow.alpha = 0.5
        scoreShadow.position = CGPoint(x: 2, y: -2)
        scoreShadow.zPosition = -1
        scoreShadow.text = "Score: 0"
        scoreLabel.addChild(scoreShadow)
        addChild(scoreLabel)

        // Lives with heart icons
        let heartIcon = SKSpriteNode(imageNamed: "IconHeart")
        heartIcon.setScale(0.3)
        heartIcon.position = CGPoint(x: size.width - 100, y: size.height - 40)
        heartIcon.zPosition = 100
        addChild(heartIcon)

        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.fontSize = 26
        livesLabel.position = CGPoint(x: size.width - 70, y: size.height - 50)
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.zPosition = 100
        livesLabel.fontColor = .white
        livesLabel.text = "3"

        let livesShadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesShadow.fontSize = 26
        livesShadow.fontColor = .black
        livesShadow.alpha = 0.5
        livesShadow.position = CGPoint(x: 2, y: -2)
        livesShadow.zPosition = -1
        livesShadow.text = "3"
        livesLabel.addChild(livesShadow)
        addChild(livesLabel)

        // Shots label with icon
        shotsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shotsLabel.fontSize = 22
        shotsLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        shotsLabel.horizontalAlignmentMode = .center
        shotsLabel.zPosition = 100
        shotsLabel.fontColor = SKColor(red: 0.5, green: 1.0, blue: 1.0, alpha: 1.0)
        shotsLabel.text = "⚡ 5"
        addChild(shotsLabel)
    }

    private func createLevel(_ level: Int) {
        // Clear existing objects
        orbitingObjects.forEach { $0.removeFromParent() }
        orbitingObjects.removeAll()

        targetY = size.height - 150

        // Create goal zone at top
        let goalZone = SKShapeNode(rectOf: CGSize(width: size.width, height: 100))
        goalZone.fillColor = SKColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 0.3)
        goalZone.strokeColor = .green
        goalZone.lineWidth = 2
        goalZone.position = CGPoint(x: size.width / 2, y: size.height - 50)
        goalZone.zPosition = -1
        goalZone.name = "goal"
        addChild(goalZone)

        let levelSpacing = size.height / 8

        // Level 1: Simple circular orbits
        createOrbitLane(
            y: 200,
            count: 3,
            orbitType: .circular(radius: 60),
            speed: 0.1,
            isHazard: true
        )

        createOrbitLane(
            y: 200 + levelSpacing,
            count: 4,
            orbitType: .elliptical(radiusX: 80, radiusY: 40),
            speed: 0.15,
            isHazard: true
        )

        createOrbitLane(
            y: 200 + levelSpacing * 2,
            count: 2,
            orbitType: .figure8(width: 100, height: 50),
            speed: 0.12,
            isHazard: true
        )

        createOrbitLane(
            y: 200 + levelSpacing * 3,
            count: 3,
            orbitType: .wavy(amplitude: 40, wavelength: size.width, direction: 0),
            speed: 0.08,
            isHazard: true
        )

        // Add safe planets to land on
        createSafePlanet(at: CGPoint(x: size.width / 4, y: 300))
        createSafePlanet(at: CGPoint(x: 3 * size.width / 4, y: 500))
    }

    private func createOrbitLane(y: CGFloat, count: Int, orbitType: OrbitType, speed: CGFloat, isHazard: Bool) {
        let spacing = size.width / CGFloat(count + 1)

        for i in 0..<count {
            let x = spacing * CGFloat(i + 1)
            let center = CGPoint(x: x, y: y)

            // Create planet/asteroid texture
            let texture = createCelestialTexture(isHazard: isHazard)

            let object = OrbitingObject(
                texture: texture,
                orbitType: orbitType,
                center: center,
                speed: speed
            )
            object.isHazard = isHazard
            object.canBeDestroyed = isHazard
            object.zPosition = 5
            object.orbitProgress = CGFloat(i) / CGFloat(count) // Stagger starting positions

            addChild(object)
            orbitingObjects.append(object)
        }
    }

    private func createSafePlanet(at position: CGPoint) {
        let texture = createCelestialTexture(isHazard: false)
        let planet = OrbitingObject(
            texture: texture,
            orbitType: .circular(radius: 0), // Stationary
            center: position,
            speed: 0
        )
        planet.isHazard = false
        planet.isSafeZone = true
        planet.canBeDestroyed = false
        planet.zPosition = 5
        planet.setScale(1.3) // Make safe planets larger

        // Add gentle pulse animation with glow
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 1.0),
            SKAction.scale(to: 1.3, duration: 1.0)
        ])
        planet.run(SKAction.repeatForever(pulse))

        // Add glow effect
        let glow = SKSpriteNode(imageNamed: "spark")
        glow.setScale(3.0)
        glow.alpha = 0.3
        glow.zPosition = -1
        glow.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 1.0),
            SKAction.fadeAlpha(to: 0.3, duration: 1.0)
        ])))
        planet.addChild(glow)

        addChild(planet)
        orbitingObjects.append(planet)
    }

    private func createCelestialTexture(isHazard: Bool) -> SKTexture {
        // Use beautiful pre-made textures
        if isHazard {
            // Randomly select asteroid or hazard planet
            let textures = ["Asteroid1", "Asteroid2", "Asteroid3", "PlanetHazard", "PlanetPurple"]
            return SKTexture(imageNamed: textures.randomElement()!)
        } else {
            return SKTexture(imageNamed: "PlanetSafe")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Simple tap to move for now (can be enhanced with swipe gestures)
        player.jump(to: location)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update all orbiting objects
        for object in orbitingObjects {
            object.update(deltaTime: deltaTime)
        }

        // Check if player reached goal
        if player.position.y > targetY {
            levelComplete()
        }

        updateHUD()
    }

    private func updateHUD() {
        scoreLabel.text = "Score: \(player.score)"
        scoreLabel.childNode(withName: "//shadow")?.removeFromParent()
        let scoreShadow = scoreLabel.children.first as? SKLabelNode
        scoreShadow?.text = "Score: \(player.score)"

        livesLabel.text = "\(player.lives)"
        let livesShadow = livesLabel.children.first as? SKLabelNode
        livesShadow?.text = "\(player.lives)"

        shotsLabel.text = "⚡ \(player.shotCount)"
    }

    private func levelComplete() {
        player.score += 100 * currentLevel
        currentLevel += 1

        // Reset player position
        player.position = CGPoint(x: size.width / 2, y: 100)
        player.shotCount = 5 + currentLevel // More shots on higher levels

        // Show level complete message
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Level \(currentLevel - 1) Complete!"
        label.fontSize = 40
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 200
        addChild(label)

        label.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])) {
            self.createLevel(self.currentLevel)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // Check player collision with hazard
        if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2) ||
           (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) {
            playerHit()
        }

        // Check projectile collision with hazard
        if (bodyA.categoryBitMask == 8 && bodyB.categoryBitMask == 2) {
            bodyA.node?.removeFromParent()
            if let object = bodyB.node as? OrbitingObject, object.canBeDestroyed {
                destroyObject(object)
            }
        } else if (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 8) {
            bodyB.node?.removeFromParent()
            if let object = bodyA.node as? OrbitingObject, object.canBeDestroyed {
                destroyObject(object)
            }
        }
    }

    private func playerHit() {
        player.lives -= 1

        if player.lives <= 0 {
            gameOver()
        } else {
            // Reset player position with invincibility
            player.position = CGPoint(x: size.width / 2, y: 100)

            // Flash effect
            player.run(SKAction.sequence([
                SKAction.repeat(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.1),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                ]), count: 5)
            ]))
        }
    }

    private func destroyObject(_ object: OrbitingObject) {
        // Beautiful explosion effect using custom particle texture
        let explosion = SKEmitterNode()
        explosion.particleTexture = SKTexture(imageNamed: "ExplosionParticle")
        explosion.particleBirthRate = 150
        explosion.numParticlesToEmit = 30
        explosion.particleLifetime = 0.8
        explosion.particleScale = 0.5
        explosion.particleScaleSpeed = -0.3
        explosion.particleAlpha = 1.0
        explosion.particleAlphaSpeed = -1.5
        explosion.particleColor = .orange
        explosion.particleColorBlendFactor = 0.5
        explosion.emissionAngleRange = .pi * 2
        explosion.particleSpeed = 100
        explosion.particleSpeedRange = 50
        explosion.position = object.position
        explosion.zPosition = 50
        addChild(explosion)

        // Flash effect
        let flash = SKSpriteNode(imageNamed: "spark")
        flash.position = object.position
        flash.setScale(0.1)
        flash.zPosition = 49
        addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.scale(to: 2.0, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))

        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))

        object.removeFromParent()
        if let index = orbitingObjects.firstIndex(of: object) {
            orbitingObjects.remove(at: index)
        }

        player.score += 10

        // Play sound effect (when audio is added)
        // AudioManager.shared.playSoundEffect(named: AudioManager.SoundEffect.explosion)
    }

    private func gameOver() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Game Over"
        label.fontSize = 60
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.zPosition = 200
        addChild(label)

        let scoreText = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreText.text = "Final Score: \(player.score)"
        scoreText.fontSize = 30
        scoreText.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        scoreText.zPosition = 200
        addChild(scoreText)

        // Restart after delay
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let newScene = GameScene(size: self.size)
                self.view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 1.0))
            }
        ]))
    }
}
