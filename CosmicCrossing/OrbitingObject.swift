import SpriteKit

/// Represents different types of orbital paths
enum OrbitType {
    case circular(radius: CGFloat)
    case elliptical(radiusX: CGFloat, radiusY: CGFloat)
    case spiral(radiusStart: CGFloat, radiusEnd: CGFloat, rotations: CGFloat)
    case figure8(width: CGFloat, height: CGFloat)
    case wavy(amplitude: CGFloat, wavelength: CGFloat, direction: CGFloat)
}

/// An object that moves along an orbital path
class OrbitingObject: SKSpriteNode {

    var orbitType: OrbitType
    var orbitSpeed: CGFloat
    var orbitCenter: CGPoint
    var currentAngle: CGFloat = 0
    var orbitProgress: CGFloat = 0 // 0 to 1 for complete orbit

    var isHazard: Bool = true
    var isSafeZone: Bool = false
    var canBeDestroyed: Bool = false

    init(texture: SKTexture?, orbitType: OrbitType, center: CGPoint, speed: CGFloat) {
        self.orbitType = orbitType
        self.orbitSpeed = speed
        self.orbitCenter = center

        super.init(texture: texture, color: .clear, size: texture?.size() ?? CGSize(width: 40, height: 40))

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = isHazard ? 2 : 4
        physicsBody?.contactTestBitMask = 1
        physicsBody?.collisionBitMask = 0
    }

    func update(deltaTime: TimeInterval) {
        orbitProgress += orbitSpeed * CGFloat(deltaTime)
        if orbitProgress > 1.0 {
            orbitProgress -= 1.0
        }

        let newPosition = calculatePosition(progress: orbitProgress)
        position = newPosition

        // Add slight rotation for visual interest
        zRotation += orbitSpeed * CGFloat(deltaTime) * 0.5
    }

    private func calculatePosition(progress: CGFloat) -> CGPoint {
        let angle = progress * 2 * .pi

        switch orbitType {
        case .circular(let radius):
            return CGPoint(
                x: orbitCenter.x + cos(angle) * radius,
                y: orbitCenter.y + sin(angle) * radius
            )

        case .elliptical(let radiusX, let radiusY):
            return CGPoint(
                x: orbitCenter.x + cos(angle) * radiusX,
                y: orbitCenter.y + sin(angle) * radiusY
            )

        case .spiral(let radiusStart, let radiusEnd, let rotations):
            let currentRadius = radiusStart + (radiusEnd - radiusStart) * progress
            let spiralAngle = angle * rotations
            return CGPoint(
                x: orbitCenter.x + cos(spiralAngle) * currentRadius,
                y: orbitCenter.y + sin(spiralAngle) * currentRadius
            )

        case .figure8(let width, let height):
            // Lissajous curve for figure-8 pattern
            return CGPoint(
                x: orbitCenter.x + sin(angle) * width,
                y: orbitCenter.y + sin(angle * 2) * height
            )

        case .wavy(let amplitude, let wavelength, let direction):
            // Wave pattern moving in a direction
            let directionRadians = direction * .pi / 180
            let baseX = progress * wavelength
            let baseY = sin(progress * 2 * .pi * 3) * amplitude

            return CGPoint(
                x: orbitCenter.x + cos(directionRadians) * baseX - sin(directionRadians) * baseY,
                y: orbitCenter.y + sin(directionRadians) * baseX + cos(directionRadians) * baseY
            )
        }
    }
}
