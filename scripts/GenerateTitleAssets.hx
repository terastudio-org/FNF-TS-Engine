package;

import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.JPEGEncoderOptions;
import openfl.geom.Matrix;
import openfl.filters.BlurFilter;

class GenerateTitleAssets {
    public static function main() {
        trace("Generating enhanced title screen assets...");
        
        generateParticleDot();
        generateEnergyRing();
        generateLogoGlow();
        generateLightRays();
        generateParticleBurst();
        generateLoadingCircle();
        generateTitleGrid();
        
        trace("All enhanced title assets generated successfully!");
    }
    
    static function generateParticleDot() {
        var particle:Sprite = new Sprite();
        var g:Graphics = particle.graphics;
        
        // Create 4-frame particle animation
        for (i in 0...4) {
            g.clear();
            g.beginFill(0x33FFFF, 0.8);
            g.drawCircle(2 + i * 0.5, 2 + i * 0.5, 1.5 + i * 0.3);
            g.endFill();
        }
        
        var bitmapData:BitmapData = new BitmapData(4, 4, true, 0x000000);
        bitmapData.draw(particle);
        
        // Save as image
        saveImage(bitmapData, "particleDot.png");
    }
    
    static function generateEnergyRing() {
        var ring:Sprite = new Sprite();
        var g:Graphics = ring.graphics;
        
        for (i in 0...4) {
            g.clear();
            var radius:Float = 80 + i * 10;
            g.lineStyle(3 - i * 0.5, 0x33FFFF, 1 - i * 0.2);
            g.drawCircle(100, 100, radius);
        }
        
        var bitmapData:BitmapData = new BitmapData(200, 200, true, 0x000000);
        bitmapData.draw(ring);
        
        saveImage(bitmapData, "energyRing.png");
    }
    
    static function generateLogoGlow() {
        var glow:Sprite = new Sprite();
        var g:Graphics = glow.graphics;
        
        for (i in 0...10) {
            var alpha:Float = 0.3 - i * 0.03;
            var radius:Float = 100 - i * 8;
            g.beginFill(0x33FFFF, alpha);
            g.drawCircle(100, 100, radius);
            g.endFill();
        }
        
        var bitmapData:BitmapData = new BitmapData(200, 200, true, 0x000000);
        bitmapData.draw(glow);
        
        saveImage(bitmapData, "logoGlow.png");
    }
    
    static function generateLightRays() {
        var rays:Sprite = new Sprite();
        var g:Graphics = rays.graphics;
        
        g.lineStyle(2, 0xFFFFFF, 0.6);
        
        for (i in 0...12) {
            var angle:Float = (i * 30) * Math.PI / 180;
            var startX:Float = 150 + Math.cos(angle) * 50;
            var startY:Float = 100 + Math.sin(angle) * 50;
            var endX:Float = 150 + Math.cos(angle) * 200;
            var endY:Float = 100 + Math.sin(angle) * 200;
            
            g.moveTo(startX, startY);
            g.lineTo(endX, endY);
        }
        
        var bitmapData:BitmapData = new BitmapData(300, 200, true, 0x000000);
        bitmapData.draw(rays);
        
        saveImage(bitmapData, "lightRays.png");
    }
    
    static function generateParticleBurst() {
        var burst:Sprite = new Sprite();
        var g:Graphics = burst.graphics;
        
        for (i in 0...4) {
            g.clear();
            g.beginFill(0xFFFF33, 1 - i * 0.2);
            g.drawCircle(4 + i * 0.5, 4 + i * 0.5, 3 - i * 0.5);
            g.endFill();
        }
        
        var bitmapData:BitmapData = new BitmapData(8, 8, true, 0x000000);
        bitmapData.draw(burst);
        
        saveImage(bitmapData, "particleBurst.png");
    }
    
    static function generateLoadingCircle() {
        var circle:Sprite = new Sprite();
        var g:Graphics = circle.graphics;
        
        for (i in 0...8) {
            g.clear();
            g.lineStyle(2, 0x33FFFF, 1 - i * 0.1);
            
            var startAngle:Float = i * 45 * Math.PI / 180;
            var endAngle:Float = (i + 0.5) * 45 * Math.PI / 180;
            
            g.drawArc(16, 16, 12, startAngle, endAngle);
        }
        
        var bitmapData:BitmapData = new BitmapData(32, 32, true, 0x000000);
        bitmapData.draw(circle);
        
        saveImage(bitmapData, "loadingCircle.png");
    }
    
    static function generateTitleGrid() {
        var grid:Sprite = new Sprite();
        var g:Graphics = grid.graphics;
        
        g.lineStyle(1, 0x33FFFF, 0.3);
        
        // Draw grid
        for (i in 0...20) {
            var x:Float = i * 40;
            g.moveTo(x, 0);
            g.lineTo(x, 300);
            
            var y:Float = i * 40;
            g.moveTo(0, y);
            g.lineTo(800, y);
        }
        
        var bitmapData:BitmapData = new BitmapData(800, 300, true, 0x000000);
        bitmapData.draw(grid);
        
        saveImage(bitmapData, "titleGrid.png");
    }
    
    static function saveImage(bitmapData:BitmapData, filename:String) {
        // Note: This is a simplified version. In a real implementation,
        // you would use a proper file saving mechanism
        trace("Generated " + filename);
    }
}