#!/usr/bin/env bash

# Enhanced Title Screen Asset Generator
# Creates placeholder graphics for the enhanced title screen effects

echo "Generating Enhanced Title Screen Assets..."

# Create images directory if it doesn't exist
mkdir -p assets/images

# Generate particleDot.png (4x4 pixel, 4 frames)
echo "Creating particleDot.png..."
cat > generate_particle_dot.py << 'EOF'
from PIL import Image, ImageDraw
import os

# Create 4x4 pixel particle with 4 frames
frames = []
colors = [(51, 255, 255, 200), (51, 255, 255, 180), (51, 255, 255, 160), (51, 255, 255, 140)]

for i, color in enumerate(colors):
    img = Image.new('RGBA', (4, 4), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    size = 1 + i * 0.5
    draw.ellipse([2-size/2, 2-size/2, 2+size/2, 2+size/2], fill=color)
    frames.append(img)

frames[0].save('particleDot.png', save_all=True, append_images=frames[1:], duration=100, loop=0)
print("Generated particleDot.png")
EOF

python3 generate_particle_dot.py

# Generate energyRing.png (200x200, 4 frames)
echo "Creating energyRing.png..."
cat > generate_energy_ring.py << 'EOF'
from PIL import Image, ImageDraw
import os

frames = []
size = 200
center = size // 2

for i in range(4):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    radius = 80 + i * 10
    for j in range(10):
        ring_radius = radius - j * 8
        alpha = max(0, 255 - j * 25 - i * 20)
        if ring_radius > 0:
            draw.ellipse([center-ring_radius, center-ring_radius, center+ring_radius, center+ring_radius], 
                        outline=(51, 255, 255, alpha), width=2)
    
    frames.append(img)

frames[0].save('energyRing.png', save_all=True, append_images=frames[1:], duration=150, loop=0)
print("Generated energyRing.png")
EOF

python3 generate_energy_ring.py

# Generate logoGlow.png (200x200 radial gradient)
echo "Creating logoGlow.png..."
cat > generate_logo_glow.py << 'EOF'
from PIL import Image, ImageDraw
import os

size = 200
center = size // 2
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Create radial gradient
for i in range(100):
    radius = i
    alpha = max(0, 200 - i * 2)
    color = (51, 255, 255, alpha)
    draw.ellipse([center-radius, center-radius, center+radius, center+radius], fill=color)

img.save('logoGlow.png')
print("Generated logoGlow.png")
EOF

python3 generate_logo_glow.py

# Generate lightRays.png (300x200, radiating lines)
echo "Creating lightRays.png..."
cat > generate_light_rays.py << 'EOF'
from PIL import Image, ImageDraw, ImageFilter
import os

width, height = 300, 200
center_x, center_y = width // 2, height // 2
img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw radiating lines
for i in range(12):
    angle = i * 30
    end_x = center_x + 150 * (angle % 180 == 0 or angle % 180 == 30 or angle % 180 == 60)
    end_y = center_y + 150 * (angle % 180 == 90 or angle % 180 == 120 or angle % 180 == 150)
    
    # Calculate end point
    import math
    rad = math.radians(angle)
    end_x = center_x + 200 * math.cos(rad)
    end_y = center_y + 200 * math.sin(rad)
    
    # Draw line
    alpha = 153  # 60% alpha
    draw.line([center_x, center_y, end_x, end_y], fill=(255, 255, 255, alpha), width=2)

img.save('lightRays.png')
print("Generated lightRays.png")
EOF

python3 generate_light_rays.py

# Generate particleBurst.png (8x8, 4 frames)
echo "Creating particleBurst.png..."
cat > generate_particle_burst.py << 'EOF'
from PIL import Image, ImageDraw
import os

frames = []
colors = [(255, 255, 51, 255), (255, 255, 51, 220), (255, 255, 51, 180), (255, 255, 51, 140)]

for i, color in enumerate(colors):
    img = Image.new('RGBA', (8, 8), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    radius = 2 + i * 0.5
    draw.ellipse([4-radius, 4-radius, 4+radius, 4+radius], fill=color)
    frames.append(img)

frames[0].save('particleBurst.png', save_all=True, append_images=frames[1:], duration=80, loop=0)
print("Generated particleBurst.png")
EOF

python3 generate_particle_burst.py

# Generate loadingCircle.png (32x32, 8 frames)
echo "Creating loadingCircle.png..."
cat > generate_loading_circle.py << 'EOF'
from PIL import Image, ImageDraw
import os
import math

size = 32
center = size // 2
frames = []

for i in range(8):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    start_angle = i * 45 - 90
    end_angle = start_angle + 30
    
    # Convert degrees to radians
    start_rad = math.radians(start_angle)
    end_rad = math.radians(end_angle)
    
    # Calculate arc points
    start_x = center + 12 * math.cos(start_rad)
    start_y = center + 12 * math.sin(start_rad)
    end_x = center + 12 * math.cos(end_rad)
    end_y = center + 12 * math.sin(end_rad)
    
    # Draw arc
    draw.arc([center-12, center-12, center+12, center+12], start_angle, end_angle, 
             fill=(51, 255, 255, 255), width=2)
    
    frames.append(img)

frames[0].save('loadingCircle.png', save_all=True, append_images=frames[1:], duration=100, loop=0)
print("Generated loadingCircle.png")
EOF

python3 generate_loading_circle.py

# Generate titleGrid.png (800x300 grid)
echo "Creating titleGrid.png..."
cat > generate_title_grid.py << 'EOF'
from PIL import Image, ImageDraw
import os

width, height = 800, 300
img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw grid lines
line_color = (51, 255, 255, 76)  # 30% alpha

# Vertical lines
for i in range(21):
    x = i * 40
    draw.line([x, 0, x, height], fill=line_color, width=1)

# Horizontal lines
for i in range(8):
    y = i * 40
    draw.line([0, y, width, y], fill=line_color, width=1)

img.save('titleGrid.png')
print("Generated titleGrid.png")
EOF

python3 generate_title_grid.py

# Clean up temporary files
rm -f generate_*.py

echo ""
echo "✅ All enhanced title screen assets generated successfully!"
echo ""
echo "Assets created:"
echo "  - particleDot.png (4x4, 4 frames)"
echo "  - energyRing.png (200x200, 4 frames)"
echo "  - logoGlow.png (200x200 radial gradient)"
echo "  - lightRays.png (300x200 radiating lines)"
echo "  - particleBurst.png (8x8, 4 frames)"
echo "  - loadingCircle.png (32x32, 8 frames)"
echo "  - titleGrid.png (800x300 grid pattern)"
echo ""
echo "All assets are located in the current directory."
echo "Move them to your FNF-TS-Engine/assets/images/ folder."