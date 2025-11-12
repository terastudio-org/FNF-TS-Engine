package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Example integration showing how to use the new optimization system
 * This demonstrates both the old and new approaches
 */
class OptimizationExampleState extends FlxState
{
	// Example variables showing different text systems
	private var oldStyleText:Alphabet;
	private var newStyleText:FontText;
	private var optimizedMenuText:OptimizedAlphabet;
	private var utilityText:FlxText;
	
	// Performance monitoring
	private var performanceUpdateTimer:Float = 0;
	private var currentFPS:Float = 60;
	
	override function create()
	{
		super.create();
		
		// Initialize the optimization system
		trace("=== OPTIMIZATION EXAMPLE STATE ===");
		initializeOptimizationSystem();
		
		// Create background
		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(1280, 720, FlxColor.fromRGB(20, 20, 40));
		add(bg);
		
		// Compare old vs new text systems
		compareTextSystems();
		
		// Create menu example
		createMenuExample();
		
		// Create performance info
		createPerformanceInfo();
		
		trace("Optimization example initialized successfully");
	}
	
	/**
	 * Initialize the optimization system
	 */
	private function initializeOptimizationSystem():Void
	{
		// Initialize the game kernel with this state
		#if GAME_KERNEL_ENABLED
		GameKernel.init(this);
		trace("GameKernel initialized");
		#end
		
		// Get optimization system status
		var status = OptimizationUtils.getOptimizationStatus();
		trace("Optimization Status: " + status);
		
		// Get performance recommendations
		var recommendations = OptimizationUtils.getOptimizationRecommendations();
		for (recommendation in recommendations)
		{
			trace("Recommendation: " + recommendation);
		}
	}
	
	/**
	 * Compare old vs new text systems
	 */
	private function compareTextSystems():Void
	{
		var yPos:Float = 100;
		
		// Old sprite-based text (Alphabet)
		oldStyleText = new Alphabet(50, yPos, "OLD: Sprite-based text (Alphabet)", true);
		add(oldStyleText);
		yPos += 60;
		
		// New font-based text (FontText)
		#if FONT_TEXT_SYSTEM
		newStyleText = new FontText(50, yPos, 600, "NEW: Font-based text (FontText)", 24, FontText.FONT_VCR, FlxColor.CYAN, false);
		add(newStyleText);
		#else
		var fallbackText:FlxText = new FlxText(50, yPos, 600, "NEW: Font system disabled", 24);
		fallbackText.setFormat("VCR", 24, FlxColor.CYAN);
		add(fallbackText);
		#end
		yPos += 60;
		
		// Optimized Alphabet (drop-in replacement)
		optimizedMenuText = new OptimizedAlphabet(50, yPos, "OPTIMIZED: Font-based Alphabet", 24, FontText.FONT_VCR, true);
		optimizedMenuText.isMenuItem = true;
		optimizedMenuText.targetY = 0;
		optimizedMenuText.distancePerItem = 60;
		add(optimizedMenuText);
		yPos += 80;
		
		// Example of utility functions
		var availableFonts = OptimizationUtils.getAvailableFonts();
		var fontInfo = "Available Fonts: " + availableFonts.length;
		utilityText = new FlxText(50, yPos, 800, fontInfo, 16);
		utilityText.setFormat("VCR", 16, FlxColor.YELLOW);
		add(utilityText);
	}
	
	/**
	 * Create menu example with optimization
	 */
	private function createMenuExample():Void
	{
		var menuY:Float = 350;
		var menuOptions:Array<String> = [
			"Free Play", 
			"Story Mode", 
			"Options", 
			"Credits", 
			"Mods"
		];
		
		for (i in 0...menuOptions.length)
		{
			// Use optimization utils to create menu items
			var menuItem = OptimizationUtils.createMenuText(400, menuY + (i * 50), menuOptions[i]);
			menuItem.targetY = i;
			add(menuItem);
		}
	}
	
	/**
	 * Create performance monitoring display
	 */
	private function createPerformanceInfo():Void
	{
		var infoX:Float = 800;
		var infoY:Float = 100;
		var infoWidth:Float = 400;
		
		// Performance stats text
		var perfStats:FlxText = new FlxText(infoX, infoY, infoWidth, "Performance Info", 16);
		perfStats.setFormat("VCR", 16, FlxColor.GREEN);
		perfStats.scrollFactor.set(0, 0);
		add(perfStats);
		
		// Optimization status text
		var optStatus:FlxText = new FlxText(infoX, infoY + 100, infoWidth, "Optimization Status", 16);
		optStatus.setFormat("VCR", 16, FlxColor.ORANGE);
		optStatus.scrollFactor.set(0, 0);
		add(optStatus);
		
		// Update initial status
		updatePerformanceDisplay();
	}
	
	/**
	 * Update performance display
	 */
	private function updatePerformanceDisplay():Void
	{
		// Get current performance stats
		var stats = OptimizationUtils.getPerformanceStats();
		var fontStatus = OptimizationUtils.getFontSystemStatus();
		
		// Update the performance text
		var perfText = "CURRENT PERFORMANCE:\n";
		perfText += "FPS: " + Math.round(stats["currentFPS"]) + "\n";
		perfText += "Memory: " + Math.round(stats["currentMemory"]) + " MB\n";
		perfText += "Level: " + stats["optimizationLevel"] + "\n";
		
		// Update the utility text with new info
		if (utilityText != null)
		{
			var currentTime = FlxG.elapsed;
			var newText = "Available Fonts: " + OptimizationUtils.getAvailableFonts().length + 
						 "\nUptime: " + Math.round(currentTime) + "s" +
						 "\nOptimization Active: " + stats["isOptimized"];
			OptimizationUtils.safeTextSetText(utilityText, newText);
		}
	}
	
	/**
	 * Example of batch text updates
	 */
	private function demonstrateBatchUpdates():Void
	{
		// Create multiple text elements
		var textArray:Array<Dynamic> = [oldStyleText, optimizedMenuText];
		var newContent:Array<String> = [
			"UPDATED: Sprite-based text (Alphabet)",
			"UPDATED: Font-based Alphabet"
		];
		
		// Use batch update for efficiency
		OptimizationUtils.batchUpdateTexts(textArray, newContent);
	}
	
	/**
	 * Example of manual optimization
	 */
	private function demonstrateManualOptimization():Void
	{
		// Set performance level
		OptimizationUtils.setPerformanceLevel("low");
		
		// Trigger garbage collection
		OptimizationUtils.triggerOptimizationAction("gc");
		
		// Clear font cache
		OptimizationUtils.clearFontCache();
		
		trace("Manual optimization completed");
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		// Update the optimization system
		OptimizationUtils.updateOptimization();
		
		// Update performance monitoring (every 0.5 seconds)
		performanceUpdateTimer += elapsed;
		if (performanceUpdateTimer >= 0.5)
		{
			updatePerformanceDisplay();
			performanceUpdateTimer = 0;
		}
		
		// Handle input for demonstrations
		handleInputDemo();
		
		// Example of dynamic text updates
		if (FlxG.keys.justPressed.ONE)
		{
			demonstrateBatchUpdates();
		}
		
		if (FlxG.keys.justPressed.TWO)
		{
			demonstrateManualOptimization();
		}
		
		if (FlxG.keys.justPressed.THREE)
		{
			// Toggle performance display
			#if GAME_KERNEL_ENABLED
			GameKernel.togglePerformanceDisplay();
			#end
		}
	}
	
	/**
	 * Handle input for demonstration purposes
	 */
	private function handleInputDemo():Void
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			// Return to main menu or previous state
			FlxG.switchState(new MenuState());
		}
		
		if (FlxG.keys.justPressed.SPACE)
		{
			// Example of safe text updates
			var messages = [
				"SPACE: Demonstration mode active",
				"SPACE: Press ESC to return to menu",
				"SPACE: Try 1, 2, 3 for more demos"
			];
			var randomMessage = messages[FlxG.random.int(0, messages.length - 1)];
			
			if (newStyleText != null)
			{
				OptimizationUtils.safeTextSetText(newStyleText, "DEMO: " + randomMessage);
			}
		}
	}
	
	override function destroy():Void
	{
		// Clean up text objects
		if (oldStyleText != null) oldStyleText.destroy();
		if (newStyleText != null) newStyleText.destroy();
		if (optimizedMenuText != null) optimizedMenuText.destroy();
		
		super.destroy();
	}
}