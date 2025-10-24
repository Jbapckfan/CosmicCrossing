import SpriteKit

class Player: SKSpriteNode {

    var lives: Int = 3
    var score: Int = 0
    var canShoot: Bool = true
    var shotCount: Int = 5

    private var particleEmitter: SKEmitterNode?

    init() {
        // Use beautiful pre-made star texture
        let texture = SKTexture(imageNamed: "PlayerStar")
        super.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))

        setupPhysics()
        setupParticles()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = 1
        physicsBody?.contactTestBitMask = 2 | 4
        physicsBody?.collisionBitMask = 0
        physicsBody?.allowsRotation = false
    }

    private func setupParticles() {
        // Beautiful star trail effect
        particleEmitter = SKEmitterNode()
        particleEmitter?.particleTexture = SKTexture(imageNamed: "StarParticle")
        particleEmitter?.particleBirthRate = 30
        particleEmitter?.particleLifetime = 0.8
        particleEmitter?.particleScale = 0.15
        particleEmitter?.particleScaleSpeed = -0.12
        particleEmitter?.particleAlpha = 0.9
        particleEmitter?.particleAlphaSpeed = -1.2
        particleEmitter?.particleColor = .init(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        particleEmitter?.particleColorBlendFactor = 0.8
        particleEmitter?.particleColorSequence = nil
        particleEmitter?.position = CGPoint.zero
        particleEmitter?.emissionAngle = .pi
        particleEmitter?.emissionAngleRange = .pi / 3
        particleEmitter?.particleSpeed = 60
        particleEmitter?.particleSpeedRange = 30
        particleEmitter?.particleRotation = 0
        particleEmitter?.particleRotationSpeed = 2.0
        particleEmitter?.zPosition = -1

        if let emitter = particleEmitter {
            addChild(emitter)
        }
    }

    func jump(to position: CGPoint) {
        // Smooth jump animation
        let jumpHeight: CGFloat = 50
        let midPoint = CGPoint(
            x: (self.position.x + position.x) / 2,
            y: max(self.position.y, position.y) + jumpHeight
        )

        let path = UIBezierPath()
        path.move(to: self.position)
        path.addQuadCurve(to: position, controlPoint: midPoint)

        let follow = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, duration: 0.3)
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])

        run(SKAction.group([follow, rotate, scale]))
    }

    func shoot(direction: CGVector) -> SKSpriteNode? {
        guard shotCount > 0 else { return nil }

        shotCount -= 1

        // Use beautiful energy ball texture
        let texture = SKTexture(imageNamed: "EnergyBall")
        let projectile = SKSpriteNode(texture: texture, size: CGSize(width: 24, height: 24))
        projectile.position = position
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        projectile.physicsBody?.categoryBitMask = 8
        projectile.physicsBody?.contactTestBitMask = 2
        projectile.physicsBody?.collisionBitMask = 0
        projectile.physicsBody?.velocity = CGVector(dx: direction.dx * 500, dy: direction.dy * 500)
        projectile.name = "projectile"
        projectile.zPosition = 8

        // Add rotation and pulse effect
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 0.5))
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))

        projectile.run(SKAction.group([rotate, pulse]))

        // Remove after duration
        projectile.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))

        // Play sound effect (when audio is added)
        // AudioManager.shared.playSoundEffect(named: AudioManager.SoundEffect.shoot)

        return projectile
    }

    static func createStarTexture() -> SKTexture {
        // Create a simple star shape programmatically
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let outerRadius: CGFloat = 45
            let innerRadius: CGFloat = 20
            let numberOfPoints = 5

            let path = UIBezierPath()

            for i in 0..<numberOfPoints * 2 {
                let angle = CGFloat(i) * .pi / CGFloat(numberOfPoints) - .pi / 2
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let point = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )

                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }

            path.close()

            UIColor.yellow.setFill()
            path.fill()

            UIColor.white.setStroke()
            path.lineWidth = 2
            path.stroke()
        }

        return SKTexture(image: image)
    }
}
