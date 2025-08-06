# 🍕 Food Fighter - Roblox Game

A multiplayer food-throwing battle game built with Roblox Studio and Rojo.

## 🎮 Game Overview

Food Fighter is an exciting multiplayer game where players select their arsenal of food items and engage in epic battles by throwing food at each other. The game features:

- **Food Selection System**: Choose from 6 different food types with varying costs and damage
- **Budget Management**: Strategic purchasing with a $10 starting budget
- **Physics-Based Throwing**: Realistic food projectile physics
- **Multiplayer Combat**: Battle against other players in real-time
- **Visual Effects**: Particle effects, screen shake, and smooth animations
- **Scoring System**: Track hits, kills, and performance

## 🏗️ Project Structure

```
src/
├── Modules/                 # Shared modules
│   ├── FoodPhysics.lua     # Physics calculations and food properties
│   ├── FoodCollision.lua   # Collision detection and hit effects
│   ├── FoodScoring.lua     # Score tracking and statistics
│   ├── FoodSounds.lua      # Sound effects and audio management
│   └── FoodParticles.lua   # Visual effects and particle systems
├── ServerScripts/          # Server-side scripts
│   ├── ModuleSetup.lua     # Module verification and RemoteEvent creation
│   ├── FoodIntegration.lua # System integration and event handling
│   ├── MatchManager.lua    # Game state and match management
│   ├── TableSetup.lua      # Game environment setup
│   └── Baseplate.lua       # Basic game world setup
├── PlayerScripts/          # Client-side scripts
│   ├── FoodSelection.lua   # Food selection UI and logic
│   ├── FoodThrowing.lua    # Throwing mechanics and input handling
│   ├── CameraControl.lua   # Camera system and controls
│   ├── ScreenShake.lua     # Screen shake effects
│   └── UIManager.lua       # UI management and updates
└── Shared/                 # Shared configuration
    └── GameConfig.lua      # Game constants and settings
```

## 🚀 Getting Started

### Prerequisites

- [Roblox Studio](https://www.roblox.com/create)
- [Rojo](https://rojo.space/) - For syncing files to Roblox Studio
- [Git](https://git-scm.com/) - For version control

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/allawr3/robloxdev.git
   cd robloxdev
   ```

2. **Install Rojo** (if not already installed):
   ```bash
   npm install -g @rojo/cli
   ```

3. **Start Rojo server**:
   ```bash
   rojo serve
   ```

4. **Connect to Roblox Studio**:
   - Open Roblox Studio
   - Install the Rojo plugin
   - Connect to the Rojo server
   - The project will sync automatically

## 🎯 Game Features

### Food Selection System
- **6 Food Types**: Fries, Donut, Hotdog, Juice Box, Pizza Slice, Chicken Leg
- **Budget Management**: $10 starting budget with strategic purchasing
- **Multiple Quantities**: Buy multiple of the same food type
- **Enhanced UI**: Rounded corners, glow effects, and smooth animations

### Throwing Mechanics
- **Physics-Based**: Realistic projectile trajectories
- **Multiple Food Types**: Each food has unique properties (speed, damage, arc)
- **Visual Feedback**: Trajectory preview and impact effects
- **Sound Effects**: Throw and hit sounds for each food type

### Multiplayer Features
- **Real-Time Combat**: Synchronized throwing and hit detection
- **Scoring System**: Track hits, kills, and performance
- **Match Management**: Game state and player management
- **RemoteEvents**: Secure client-server communication

## 🔧 Technical Details

### Architecture
- **Modular Design**: Separated concerns with dedicated modules
- **Safe Loading**: Non-blocking module loading with error handling
- **Event-Driven**: RemoteEvents for client-server communication
- **Performance Optimized**: Efficient UI updates and physics calculations

### Key Scripts
- **ModuleSetup.lua**: Ensures all modules and RemoteEvents are available
- **FoodIntegration.lua**: Connects all game systems safely
- **FoodSelection.lua**: Enhanced UI with multiple food selection
- **FoodThrowing.lua**: Physics-based throwing mechanics

### Error Handling
- **Graceful Fallbacks**: Systems continue working even if modules are missing
- **Safe Loading**: No infinite waits or blocking operations
- **Debug Output**: Comprehensive logging for troubleshooting

## 🎨 UI/UX Features

- **Modern Design**: Clean, rounded UI elements
- **Visual Feedback**: Glow effects, color coding, and animations
- **Responsive Layout**: Adapts to different screen sizes
- **Accessibility**: Clear text and intuitive controls

## 🐛 Recent Fixes

The project has been extensively tested and debugged to eliminate common issues:

- ✅ **No Infinite Yields**: All WaitForChild calls have timeouts
- ✅ **No Permission Errors**: Removed dynamic .Source setting
- ✅ **No Syntax Errors**: All require statements are complete
- ✅ **Non-blocking UI**: Food selection never blocks the interface

## 📝 Development Notes

### File Structure
- **Static Modules**: All modules are synced by Rojo (no dynamic creation)
- **Safe Loading**: All scripts use safe loading patterns
- **Error Handling**: Comprehensive error handling throughout

### Testing
- **Module Verification**: ModuleSetup.lua verifies all required modules
- **RemoteEvent Creation**: Automatic creation of all required RemoteEvents
- **Fallback Behavior**: Systems work even with missing dependencies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Roblox Studio for the development platform
- Rojo for seamless file synchronization
- The Roblox developer community for inspiration and support

---

**Ready to fight?** 🚀 Select your arsenal and enter the battle! 