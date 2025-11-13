# Enhanced Title Screen Integration Patch

## Method 1: Replace Main Title Screen (Recommended)

### Step 1: Replace TitleState.hx
```bash
# Backup original
cp source/TitleState.hx source/TitleState.hx.backup

# Replace with enhanced version
cp source/EnhancedTitleState.hx source/TitleState.hx
```

### Step 2: Add Define to Project.xml
Add to your `<haxedef>` section:
```xml
<haxedef name="ENHANCED_TITLE" />
```

## Method 2: Conditional Integration

### Update Main.hx or MainMenuState.hx
Replace the title screen state selection:

```haxe
// In your main state switching logic
#if ENHANCED_TITLE
FlxG.switchState(new EnhancedTitleState());
#else
FlxG.switchState(new TitleState());
#end
```

## Method 3: Menu Integration

### Update EnhancedMainMenuState.hx
Add this to the main menu transition back to title:

```haxe
// In EnhancedMainMenuState.hx, find the "Exit to Title" function
function exitToTitle() {
    #if ENHANCED_TITLE
    FlxG.switchState(new EnhancedTitleState());
    #else
    FlxG.switchState(new TitleState());
    #end
}
```

## Configuration Steps

### 1. Copy Configuration File
```bash
cp assets/data/enhancedTitleConfig.json assets/data/enhancedTitleConfig.json.backup
```

### 2. Generate Required Assets
The enhanced title screen references several graphic assets:

#### Option A: Use Generator Script
```bash
# If you have Python with PIL installed:
python3 generate_enhanced_title_assets.py
```

#### Option B: Manual Creation
Create these files in `assets/images/`:
- `particleDot.png` - 4x4 pixel particles (cyan glow)
- `energyRing.png` - 200x200 energy ring effects
- `logoGlow.png` - 200x200 radial glow
- `lightRays.png` - 300x200 light beams
- `particleBurst.png` - 8x8 explosion particles
- `loadingCircle.png` - 32x32 spinning indicator
- `titleGrid.png` - 800x300 animated grid

### 3. Add Assets Include
Update Project.xml:
```xml
<includeAssets>
    <asset path="assets/images" />
</includeAssets>
```

## Testing the Integration

### Build Commands
```bash
# Standard build
lime build neko

# HTML5 build
lime build html5

# Desktop build (if available)
lime build windows
```

### Verification Checklist
- [ ] Title screen loads without errors
- [ ] Particles are visible and animating
- [ ] Logo has glow/trail effects (if enabled)
- [ ] Title text responds to hover
- [ ] Beat-reactive animations sync to music
- [ ] Performance is acceptable
- [ ] Pressing Enter transitions smoothly
- [ ] All config options work correctly

## Performance Optimization

### Low-End Device Support
Add to Project.xml:
```xml
<haxedef name="ENHANCED_TITLE_PERFORMANCE" />
```

Then modify the config:
```json
{
    "performanceMode": true,
    "particleCount": 25,
    "trailEffects": false,
    "lightingEffects": false
}
```

### Quality Presets
Create multiple config files:
- `enhancedTitleConfig_high.json` - Maximum quality
- `enhancedTitleConfig_medium.json` - Balanced performance
- `enhancedTitleConfig_low.json` - Minimum requirements

## Troubleshooting

### Common Issues

#### Assets Not Loading
```bash
# Check file paths
ls assets/images/particle*
ls assets/data/enhancedTitleConfig.json

# Verify file formats (should be PNG for images)
file assets/images/*
```

#### Performance Issues
Enable performance mode in config:
```json
{
    "performanceMode": true,
    "particleCount": 25,
    "trailEffects": false
}
```

#### Colors Not Displaying
Check for transparency support:
- Images should have alpha channel
- Use PNG format, not JPG
- Verify blend mode settings

#### Animation Issues
Verify timing:
```json
{
    "particleSpawnRate": 0.1,
    "colorCycleSpeed": 0.5,
    "energyRingRotation": 30
}
```

## Customization Examples

### Custom Color Theme
```json
{
    "dynamicColors": {
        "primary": [255, 0, 120, 255],    // Hot pink
        "secondary": [0, 120, 255, 255],  // Sky blue
        "accent1": [255, 120, 0, 255],    // Orange
        "accent2": [120, 255, 0, 255]     // Lime green
    }
}
```

### Reduced Effects for Lower-End Devices
```json
{
    "particles": false,
    "trailEffects": false,
    "waveEffects": false,
    "lightingEffects": false,
    "performanceMode": true,
    "particleCount": 10
}
```

### Maximum Visual Impact
```json
{
    "particles": true,
    "trailEffects": true,
    "waveEffects": true,
    "lightingEffects": true,
    "particleCount": 100,
    "energyRings": 5,
    "floatingTexts": 10
}
```

## Build Integration

### Pre-Build Hook
Add to your build script:
```bash
# Generate assets if needed
if [ ! -f "assets/images/particleDot.png" ]; then
    echo "Generating enhanced title assets..."
    python3 generate_enhanced_title_assets.py
fi
```

### Post-Build Verification
```bash
# Verify assets are included
if [ ! -f "export/release/assets/images/particleDot.png" ]; then
    echo "ERROR: Enhanced title assets missing from build!"
    exit 1
fi
```

## Version Compatibility

### HaxeFlixel Version Support
- **4.11+**: Full support for all effects
- **4.10-4.11**: Most effects work, some performance limitations
- **<4.10**: Reduced functionality, upgrade recommended

### OpenFL Version Support
- **OpenFL 9+**: Recommended
- **OpenFL 8**: Basic functionality
- **OpenFL <8**: Compatibility issues likely

## Uninstallation

To revert to the original title screen:

### Step 1: Restore Original
```bash
# Restore backup
cp source/TitleState.hx.backup source/TitleState.hx

# Remove enhanced files
rm source/EnhancedTitleState.hx
rm assets/data/enhancedTitleConfig.json
```

### Step 2: Update Project.xml
Remove the define:
```xml
<!-- <haxedef name="ENHANCED_TITLE" /> -->
```

### Step 3: Clean Build
```bash
lime clean
lime build neko
```

## Support

For issues or questions:
1. Check the ENHANCED_TITLE_README.md for detailed documentation
2. Verify all required assets are present
3. Test with performance mode enabled
4. Check console output for error messages

The enhanced title screen is designed to be both visually impressive and performance-conscious, with multiple optimization options for different devices and preferences.