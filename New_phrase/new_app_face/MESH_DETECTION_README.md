# Mesh Detection and Animation Controller

This Flutter app implements an advanced 3D model viewer with mesh detection capabilities, allowing users to interact with different parts of a 3D model and trigger animations.

## Features

### 🎯 Mesh Detection
- **Interactive Tap Detection**: Click on different parts of the 3D model to get detailed information
- **Visual Zones**: Toggle overlay to see clickable zones on the model
- **Part Information**: Detailed popups showing part names, descriptions, and functions

### 🎬 Animation Control
- **Dynamic Animations**: Control various animations like lid operations and drawer movements
- **Animation Triggers**: Start animations directly from part information popups
- **State Management**: Smart animation state tracking with visual feedback

### 📱 User Interface
- **Responsive Design**: Optimized for different screen sizes
- **Interactive Legend**: Expandable legend showing all available parts
- **Visual Feedback**: Color-coded parts with clear visual indicators

## Implementation Details

### Core Components

1. **MeshDetectorHelper** (`mesh_detector_helper.dart`)
   - Defines mesh parts with hit zones and metadata
   - Handles coordinate-based part detection
   - Manages part information database

2. **MeshPartPopup** (`mesh_detector_helper.dart`)
   - Creates detailed information dialogs for each part
   - Integrates animation controls within popups
   - Provides rich UI with color-coded elements

3. **MeshDetectionOverlay** (`mesh_detection_overlay.dart`)
   - Renders visual overlay showing clickable zones
   - Custom painter for zone visualization
   - Toggle-able overlay system

4. **ModelAnimationScreen** (`animation_test.dart`)
   - Main screen combining all functionality
   - Gesture detection and coordinate mapping
   - Animation state management

### Mesh Parts Configuration

The system recognizes six main parts:

| Part | Color | Functions | Animations |
|------|-------|-----------|------------|
| **Primary Lid** | 🔵 Blue | Protection, Access Control, Weather Sealing | open-lid-1, close-lid-1 |
| **Secondary Lid** | 🟢 Green | Protection, Secondary Access, Dual Zone Control | lid-2-open, lid-2-close |
| **Storage Drawer** | 🟠 Orange | Storage, Organization, Easy Access | drawer-open, drawer-close |
| **Main Body** | ⚫ Gray | Support, Framework, Component Housing | - |
| **Motor Component** | 🔴 Red | Power Generation, Movement Control, Automated Operation | - |
| **Pipe System** | 🔵 Cyan | Fluid Transport, Flow Control, Pressure Regulation | - |

### Hit Zone Mapping

Each part has defined hit zones using normalized coordinates (0-1 range):

```dart
'hitZone': {
  'x': [startX, endX], // Horizontal range
  'y': [startY, endY]  // Vertical range
}
```

### Usage Instructions

1. **Basic Interaction**:
   - Tap anywhere on the 3D model to detect parts
   - View detailed information in the popup dialog
   - Use camera controls to rotate and zoom the model

2. **Animation Control**:
   - Click animation buttons in the main interface
   - Or trigger animations directly from part popups
   - Watch real-time animation state updates

3. **Zone Visualization**:
   - Use the floating action button to toggle zone overlay
   - See exact clickable areas with color-coded regions
   - Each zone shows the part name for reference

4. **Part Information**:
   - Expand the "Part Legend" to see all available parts
   - Each part shows its associated color and name
   - Quick reference for understanding the model structure

## Technical Features

- **Coordinate Normalization**: Accurate click detection regardless of screen size
- **State Management**: Proper Flutter state management with `setState()`
- **Custom Painting**: Advanced overlay rendering with `CustomPainter`
- **Gesture Detection**: Comprehensive tap handling with `GestureDetector`
- **Dynamic UI**: Responsive interface adapting to different content

## Files Structure

```
lib/pages/
├── animation_test.dart           # Main screen with integrated functionality
├── mesh_detector_helper.dart     # Core mesh detection logic and popups
└── mesh_detection_overlay.dart   # Visual overlay system
```

## Dependencies

- `flutter/material.dart` - Material Design components
- `model_viewer_plus` - 3D model rendering
- Custom mesh detection system

## Future Enhancements

- **Advanced Hit Testing**: More precise 3D coordinate mapping
- **Animation Chaining**: Sequential animation combinations
- **Sound Effects**: Audio feedback for interactions
- **Haptic Feedback**: Touch feedback for mobile devices
- **Analytics**: Usage tracking for popular parts/animations