package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import openfl.system.System;

/**
 * Game Performance Kernel for FNF-TS-Engine
 * Monitors and optimizes game performance for lower-end devices
 */
class GameKernel
{
	// Performance monitoring
	private static var frameTime:Float = 0;
	private static var fps:Float = 60;
	private static var memoryUsage:Float = 0;
	private static var renderTime:Float = 0;
	
	// Optimization thresholds
	public static var targetFPS:Float = 60;
	public static var lowMemoryThreshold:Float = 500; // MB
	public static var highRenderTimeThreshold:Float = 16.67; // ms (60 FPS)
	
	// Performance counters
	private static var frameCount:Int = 0;
	private static var lastPerformanceCheck:Float = 0;
	private static var performanceSampleRate:Float = 0.5; // Check every 0.5 seconds
	
	// Optimization state
	private static var isOptimized:Bool = false;
	private static var optimizationLevel:PerformanceLevel = PerformanceLevel.NORMAL;
	
	// Display elements (for monitoring)
	private static var performanceDisplay:FlxText;
	private static var performanceBar:FlxBar;
	
	// Performance history for trend analysis
	private static var fpsHistory:Array<Float> = [];
	private static var memoryHistory:Array<Float> = [];
	private static var maxHistoryLength:Int = 60; // 30 seconds at 60fps
	
	// Auto-optimization settings
	public static var enableAutoOptimization:Bool = true;
	public static var autoOptimizationSensitivity:Float = 0.8; // How aggressive auto-optimization is
	
	public enum PerformanceLevel
	{
		ULTRA_LOW;
		LOW;
		NORMAL;
		HIGH;
		ULTRA_HIGH;
	}
	
	/**
	 * Initialize the game kernel
	 */
	public static function init(?parentState:FlxState):Void
	{
		if (parentState != null)
		{
			createPerformanceDisplay(parentState);
		}
		
		// Set up performance monitoring
		lastPerformanceCheck = FlxG.elapsed;
		
		trace("GameKernel initialized with optimization level: " + optimizationLevel);
	}
	
	/**
	 * Update performance monitoring and optimization
	 */
	public static function update():Void
	{
		frameTime = FlxG.elapsed * 1000; // Convert to milliseconds
		fps = 1000 / frameTime;
		
		// Update memory usage
		#if cpp
		memoryUsage = System.totalMemory / (1024 * 1024); // Convert to MB
		#else
		memoryUsage = 0; // Not available on other platforms
		#end
		
		// Update performance history
		updatePerformanceHistory();
		
		frameCount++;
		
		// Check performance periodically
		if (FlxG.elapsed - lastPerformanceCheck >= performanceSampleRate)
		{
			performOptimizationCheck();
			lastPerformanceCheck = FlxG.elapsed;
		}
		
		// Update display if enabled
		if (performanceDisplay != null && performanceDisplay.visible)
		{
			updatePerformanceDisplay();
		}
	}
	
	/**
	 * Perform optimization check and apply optimizations if needed
	 */
	private static function performOptimizationCheck():Void
	{
		var avgFPS:Float = getAverageFPS();
		var avgMemory:Float = getAverageMemory();
		
		// Determine if optimization is needed
		var needsOptimization:Bool = false;
		
		if (avgFPS < targetFPS * 0.8) // Below 80% of target FPS
		{
			needsOptimization = true;
		}
		
		if (avgMemory > lowMemoryThreshold)
		{
			needsOptimization = true;
		}
		
		if (enableAutoOptimization && needsOptimization)
		{
			applyAutoOptimizations();
		}
		
		// Log performance if it drops significantly
		if (avgFPS < 30)
		{
			trace("Low FPS detected: " + avgFPS + " | Memory: " + avgMemory + "MB");
		}
	}
	
	/**
	 * Apply automatic optimizations based on current performance
	 */
	private static function applyAutoOptimizations():Void
	{
		var avgFPS:Float = getAverageFPS();
		var avgMemory:Float = getAverageMemory();
		
		if (avgFPS < 30) // Very low FPS
		{
			setPerformanceLevel(PerformanceLevel.ULTRA_LOW);
		}
		else if (avgFPS < 45) // Low FPS
		{
			setPerformanceLevel(PerformanceLevel.LOW);
		}
		else if (avgFPS < 55) // Borderline FPS
		{
			setPerformanceLevel(PerformanceLevel.NORMAL);
		}
		else // Good FPS
		{
			setPerformanceLevel(PerformanceLevel.HIGH);
		}
		
		// Memory-based optimizations
		if (avgMemory > lowMemoryThreshold)
		{
			triggerGarbageCollection();
		}
	}
	
	/**
	 * Set the performance optimization level
	 */
	public static function setPerformanceLevel(level:PerformanceLevel):Void
	{
		if (optimizationLevel == level) return;
		
		optimizationLevel = level;
		
		switch (level)
		{
			case PerformanceLevel.ULTRA_LOW:
				applyUltraLowOptimizations();
			case PerformanceLevel.LOW:
				applyLowOptimizations();
			case PerformanceLevel.NORMAL:
				applyNormalOptimizations();
			case PerformanceLevel.HIGH:
				applyHighOptimizations();
			case PerformanceLevel.ULTRA_HIGH:
				applyUltraHighOptimizations();
		}
		
		isOptimized = true;
		trace("Performance level set to: " + level);
	}
	
	/**
	 * Ultra-low performance optimizations for very low-end devices
	 */
	private static function applyUltraLowOptimizations():Void
	{
		// Reduce visual quality significantly
		FlxG.consoleBool = false;
		
		// Limit framerate to 30 FPS
		FlxG.drawFramerate = 30;
		
		// Disable non-essential features
		ClientPrefs.globalAntialiasing = false;
		ClientPrefs.lowQuality = true;
		ClientPrefs.noteSplashes = false;
		
		// Reduce particle effects
		// This would integrate with particle systems in the game
		
		trace("Applied ultra-low optimizations");
	}
	
	/**
	 * Low performance optimizations
	 */
	private static function applyLowOptimizations():Void
	{
		// Slight quality reduction
		FlxG.drawFramerate = 45;
		ClientPrefs.globalAntiasing = true;
		ClientPrefs.lowQuality = false;
		ClientPrefs.noteSplashes = false;
		
		// Reduce some visual effects
		// This would disable expensive shaders/effects
		
		trace("Applied low optimizations");
	}
	
	/**
	 * Normal performance settings
	 */
	private static function applyNormalOptimizations():Void
	{
		FlxG.drawFramerate = 60;
		ClientPrefs.globalAntialiasing = true;
		ClientPrefs.lowQuality = false;
		ClientPrefs.noteSplashes = true;
		
		// Normal settings
		trace("Applied normal optimizations");
	}
	
	/**
	 * High performance settings
	 */
	private static function applyHighOptimizations():Void
	{
		FlxG.drawFramerate = 120; // High refresh rate monitors
		ClientPrefs.globalAntialiasing = true;
		ClientPrefs.lowQuality = false;
		ClientPrefs.noteSplashes = true;
		
		// Enable all visual effects
		trace("Applied high optimizations");
	}
	
	/**
	 * Ultra-high performance for powerful devices
	 */
	private static function applyUltraHighOptimizations():Void
	{
		FlxG.drawFramerate = 144; // Very high refresh rate
		ClientPrefs.globalAntialiasing = true;
		ClientPrefs.lowQuality = false;
		ClientPrefs.noteSplashes = true;
		
		// Enable all features and effects
		trace("Applied ultra-high optimizations");
	}
	
	/**
	 * Manual garbage collection trigger
	 */
	public static function triggerGarbageCollection():Void
	{
		#if cpp
		System.gc();
		#end
		
		// Clear font cache to free memory
		FontText.clearFontCache();
		
		trace("Garbage collection triggered");
	}
	
	/**
	 * Create performance monitoring display
	 */
	private static function createPerformanceDisplay(parentState:FlxState):Void
	{
		performanceDisplay = new FlxText(10, 10, 400, "", 12);
		performanceDisplay.setFormat("VCR", 12, FlxColor.CYAN, LEFT, OUTLINE, FlxColor.BLACK);
		performanceDisplay.scrollFactor.set(0, 0);
		parentState.add(performanceDisplay);
		
		performanceBar = new FlxBar(10, 60, LEFT_TO_RIGHT, 200, 10, null, 0, 100, true);
		performanceBar.createFilledBar(FlxColor.GREEN, FlxColor.RED);
		performanceBar.value = 100;
		performanceBar.scrollFactor.set(0, 0);
		parentState.add(performanceBar);
	}
	
	/**
	 * Update performance display
	 */
	private static function updatePerformanceDisplay():Void
	{
		var avgFPS:Float = getAverageFPS();
		var fpsPercent:Float = Math.min(100, (avgFPS / targetFPS) * 100);
		
		performanceDisplay.text = 
			"FPS: " + Math.round(avgFPS) + 
			"\nMemory: " + Math.round(memoryUsage) + " MB" +
			"\nOptimization: " + optimizationLevel +
			"\nLevel: " + (isOptimized ? "OPTIMIZED" : "NORMAL");
		
		performanceBar.value = fpsPercent;
	}
	
	/**
	 * Update performance history arrays
	 */
	private static function updatePerformanceHistory():Void
	{
		fpsHistory.push(fps);
		memoryHistory.push(memoryUsage);
		
		// Limit history length
		if (fpsHistory.length > maxHistoryLength)
		{
			fpsHistory.shift();
		}
		
		if (memoryHistory.length > maxHistoryLength)
		{
			memoryHistory.shift();
		}
	}
	
	/**
	 * Get average FPS from history
	 */
	private static function getAverageFPS():Float
	{
		if (fpsHistory.length == 0) return 60;
		
		var sum:Float = 0;
		for (fpsValue in fpsHistory)
		{
			sum += fpsValue;
		}
		
		return sum / fpsHistory.length;
	}
	
	/**
	 * Get average memory usage from history
	 */
	private static function getAverageMemory():Float
	{
		if (memoryHistory.length == 0) return 0;
		
		var sum:Float = 0;
		for (memoryValue in memoryHistory)
		{
			sum += memoryValue;
		}
		
		return sum / memoryHistory.length;
	}
	
	/**
	 * Get current performance statistics
	 */
	public static function getPerformanceStats():Map<String, Dynamic>
	{
		return [
			"currentFPS" => fps,
			"avgFPS" => getAverageFPS(),
			"currentMemory" => memoryUsage,
			"avgMemory" => getAverageMemory(),
			"optimizationLevel" => optimizationLevel,
			"isOptimized" => isOptimized
		];
	}
	
	/**
	 * Show/hide performance display
	 */
	public static function togglePerformanceDisplay():Void
	{
		if (performanceDisplay != null)
		{
			performanceDisplay.visible = !performanceDisplay.visible;
		}
		
		if (performanceBar != null)
		{
			performanceBar.visible = !performanceBar.visible;
		}
	}
	
	/**
	 * Reset performance history
	 */
	public static function resetPerformanceHistory():Void
	{
		fpsHistory = [];
		memoryHistory = [];
		frameCount = 0;
		trace("Performance history reset");
	}
}