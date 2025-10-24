# Cosmic Crossing 🌟

A thrilling space-themed arcade game for iOS and iPadOS where you guide a brave little star across the galaxy!

## Game Concept

**Cosmic Crossing** is inspired by the classic Frogger gameplay but with a cosmic twist! Navigate your star character through dynamic orbital patterns of planets, asteroids, and celestial objects. Unlike traditional lane-based games, obstacles follow realistic orbital mechanics with elliptical, circular, spiral, and figure-8 paths.

## Features

### Core Gameplay
- **Orbital Mechanics**: Objects move in complex curved paths, not simple left-right patterns
- **Multiple Orbit Types**:
  - Circular orbits
  - Elliptical orbits
  - Spiral patterns
  - Figure-8 (Lissajous) curves
  - Wavy trajectories
- **Shooting Mechanic**: Limited shots to destroy obstacles
- **Safe Zones**: Friendly planets to land on and rest
- **Progressive Difficulty**: Levels get more challenging as you advance

### Visual Polish
- Beautiful starfield background with parallax scrolling
- Particle effects and trails
- Smooth animations and physics
- Gradient space backgrounds
- Glowing celestial bodies

### Game Mechanics
- **Lives System**: Start with 3 lives
- **Score Tracking**: Points for reaching goals and destroying obstacles
- **Limited Ammunition**: Strategic shooting with limited shots per level
- **Level Progression**: Advance through increasingly complex orbital patterns

## Technical Details

- **Platform**: iOS 15.0+, iPadOS 15.0+
- **Framework**: SpriteKit for smooth 2D gameplay
- **Language**: Swift 5.0
- **Target**: 60 FPS performance
- **Orientation**: Portrait mode

## Project Structure

```
CosmicCrossing/
├── CosmicCrossing/
│   ├── AppDelegate.swift          # App lifecycle
│   ├── GameViewController.swift   # Main view controller
│   ├── GameScene.swift            # Core game logic
│   ├── Player.swift               # Star character class
│   ├── OrbitingObject.swift       # Orbital mechanics
│   ├── Assets.xcassets/           # Game assets
│   ├── Base.lproj/                # Storyboards
│   └── Info.plist                 # App configuration
└── CosmicCrossing.xcodeproj/      # Xcode project
```

## How to Run

1. Open `CosmicCrossing.xcodeproj` in Xcode
2. Select an iOS simulator or device
3. Build and run (⌘R)

## Gameplay Tips

- **Tap** anywhere on the screen to jump your star to that location
- Watch the orbital patterns and time your jumps carefully
- Use shooting sparingly - you have limited ammunition
- Land on blue planets (safe zones) to plan your next move
- Avoid red/orange hazards (asteroids, hostile planets)
- Reach the green goal zone at the top to complete each level

## Future Enhancements

- [ ] Power-ups (shields, speed boost, multi-shot, slow-motion)
- [ ] Multiple star skins to unlock
- [ ] Daily challenges
- [ ] Leaderboards and achievements
- [ ] Sound effects and background music
- [ ] Advanced orbital patterns (gravity wells, black holes)
- [ ] Swipe gestures for directional movement
- [ ] Tutorial level
- [ ] Custom level editor

## Development

Built with love for iOS game development. The game demonstrates:
- Advanced SpriteKit techniques
- Custom physics and orbital calculations
- Smooth animations and particle effects
- Responsive touch controls
- Scalable game architecture

## License

Created for fun and learning! Feel free to use and modify.

---

**Cosmic Crossing** - Jump across the galaxy, one star at a time! ✨
