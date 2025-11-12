package options;

import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

/**
 * Enhanced optimization settings with font-based text system and game kernel
 */
class EnhancedOptimizationSubState extends BaseOptionsMenu
{
	private var performanceInfo:FlxText;
	private var fontInfo:FlxText;
	private var kernelInfo:FlxText;
	
	public function new()
	{
		title = 'Enhanced Optimization';
		rpcTitle = 'Enhanced Optimization Settings Menu';
		
		// Basic optimizations (from original)
		var option:Option = new Option('Chars & BG',
			'If unchecked, gameplay will only show the HUD.',
			'charsAndBG',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Enable GC',
			"If checked, then the game will be allowed to garbage collect, reducing RAM usage.\nIf you experience memory leaks, turn this on, and\nif you experience lag with it on then turn it off.",
			'enableGC',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Light Opponent Strums',
			"If this is unchecked, the Opponent strums won't light up when the Opponent hits a note.",
			'opponentLightStrum',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Light Botplay Strums',
			"If unchecked, the Player strums won't light when Botplay is active.",
			'botLightStrum',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Light Player Strums',
			"If unchecked, then the player strums won't light up.\nIt's as simple as that.",
			'playerLightStrum',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Ratings',
			"If unchecked, the game will not show a rating sprite when hitting a note.",
			'ratingPopups',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show Combo Numbers',
			"If unchecked, the game will not show combo numbers when hitting a note.",
			'comboPopups',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Show MS Popup',
			"If checked, hitting a note will also show how late/early you hit it.",
			'showMS',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Disable onSpawnNote Lua Calls',
			"If checked, the game will not call onSpawnNote when a note is spawned.\nIf you have a script that uses that, maybe leave it on.",
			'noSpawnFunc',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Disable Hit Lua Calls',
			"If checked, the game will not call note hit functions when a note is hit.",
			'noHitFuncs',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Disable Skip Lua Calls',
			"If checked, the game will not call note hit functions for skipped notes.",
			'noSkipFuncs',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Even LESS Botplay Lag',
			"Reduce Botplay lag even further.",
			'lessBotLag',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Max Rendered Notes: ',
			"The max amount of notes that the game can render onscreen.\nTo remove this limit, set it to 0.",
			'maxNotes',
			'int',
			0);
		addOption(option);
		option.scrollSpeed = 2000;
		option.minValue = 0;
		option.maxValue = 99999;
		option.displayFormat = '%v Notes';

		// NEW FONT-BASED TEXT OPTIMIZATIONS
		addTextHeader("=== FONT TEXT SYSTEM ===");
		
		var fontOption:Option = new Option('Enable Font Text System',
			"Use font-based text rendering instead of sprite-based text.\nProvides better performance and memory usage.",
			'enableFontText',
			'bool',
			true);
		addOption(fontOption);

		var fontCacheOption:Option = new Option('Enable Font Caching',
			"Cache font rendering for better performance.\nDisable if you experience font issues.",
			'enableFontCaching',
			'bool',
			true);
		addOption(fontCacheOption);

		var defaultFontOption:Option = new Option('Default Font: ',
			"The default font used for text rendering.",
			'defaultFont',
			'string',
			'vcr.ttf');
		defaultFontOption.displayFormat = '%s';
		defaultFontOption.addChoice('vcr.ttf', 'VCR Font');
		defaultFontOption.addChoice(' Aller_rg.ttf', 'Aller Font');
		defaultFontOption.addChoice('calibri.ttf', 'Calibri Font');
		defaultFontOption.addChoice('comic.ttf', 'Comic Sans Font');
		defaultFontOption.addChoice('pixel.otf', 'Pixel Font');
		addOption(defaultFontOption);

		// NEW GAME KERNEL OPTIMIZATIONS
		addTextHeader("=== GAME KERNEL ===");
		
		var kernelOption:Option = new Option('Enable Game Kernel',
			"Enable automatic performance monitoring and optimization.\nRecommended for lower-end devices.",
			'enableGameKernel',
			'bool',
			true);
		addOption(kernelOption);

		var autoOptOption:Option = new Option('Auto-Optimization',
			"Automatically optimize game settings based on performance.\nAggressively manages performance for lower-end devices.",
			'autoOptimization',
			'bool',
			true);
		addOption(autoOptOption);

		var performanceLevelOption:Option = new Option('Performance Level: ',
			"Manual performance optimization level.\nAuto mode will override this setting.",
			'performanceLevel',
			'string',
			'normal');
		performanceLevelOption.displayFormat = '%s';
		performanceLevelOption.addChoice('ultra_low', 'Ultra Low');
		performanceLevelOption.addChoice('low', 'Low');
		performanceLevelOption.addChoice('normal', 'Normal');
		performanceLevelOption.addChoice('high', 'High');
		performanceLevelOption.addChoice('ultra_high', 'Ultra High');
		addOption(performanceLevelOption);

		var targetFPSOption:Option = new Option('Target FPS: ',
			"The target framerate for the game.\nLower values provide better performance on weak devices.",
			'targetFPS',
			'int',
			60);
		targetFPSOption.minValue = 30;
		targetFPSOption.maxValue = 144;
		targetFPSOption.scrollSpeed = 10;
		targetFPSOption.displayFormat = '%v FPS';
		addOption(targetFPSOption);

		var memoryThresholdOption:Option = new Option('Memory Threshold (MB): ',
			"Memory usage threshold for auto-optimization.\nWhen exceeded, the game will optimize memory usage.",
			'memoryThreshold',
			'int',
			500);
		memoryThresholdOption.minValue = 100;
		memoryThresholdOption.maxValue = 2000;
		memoryThresholdOption.scrollSpeed = 50;
		memoryThresholdOption.displayFormat = '%v MB';
		addOption(memoryThresholdOption);

		var performanceDisplayOption:Option = new Option('Show Performance Display',
			"Display real-time performance monitoring.\nUseful for debugging performance issues.",
			'showPerformanceDisplay',
			'bool',
			false);
		addOption(performanceDisplayOption);

		// NEW RENDERING OPTIMIZATIONS
		addTextHeader("=== RENDERING OPTIMIZATIONS ===");
		
		var renderModeOption:Option = new Option('Render Mode: ',
			"Rendering mode for optimal performance.\nAuto detects best mode for your device.",
			'renderMode',
			'string',
			'auto');
		renderModeOption.displayFormat = '%s';
		renderModeOption.addChoice('auto', 'Auto');
		renderModeOption.addChoice('software', 'Software (Low End)');
		renderModeOption.addChoice('hardware', 'Hardware (Modern)');
		renderModeOption.addChoice('direct', 'Direct (High End)');
		addOption(renderModeOption);

		var textureFilterOption:Option = new Option('Texture Filtering: ',
			"Texture filtering quality affects performance and visuals.\nBilinear is best for performance.",
			'textureFiltering',
			'string',
			'bilinear');
		textureFilterOption.displayFormat = '%s';
		textureFilterOption.addChoice('nearest', 'Nearest (Pixel Perfect)');
		textureFilterOption.addChoice('bilinear', 'Bilinear (Fast)');
		textureFilterOption.addChoice('trilinear', 'Trilinear (Quality)');
		textureFilterOption.addChoice('anisotropic', 'Anisotropic (Best Quality)');
		addOption(textureFilterOption);

		// Add manual optimization buttons
		addTextHeader("=== MANUAL OPTIMIZATION ===");
		
		var optimizeButton:FlxButton = new FlxButton(x, y, "Optimize Now", function() {
			triggerManualOptimization();
		});
		addButton(optimizeButton);

		var gcButton:FlxButton = new FlxButton(x, y, "Force Garbage Collection", function() {
			GameKernel.triggerGarbageCollection();
		});
		addButton(gcButton);

		var resetButton:FlxButton = new FlxButton(x, y, "Reset Performance History", function() {
			GameKernel.resetPerformanceHistory();
		});
		addButton(resetButton);

		// Add information displays
		addInfoDisplays();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		super();
	}

	/**
	 * Add header text for section separation
	 */
	private function addTextHeader(text:String):Void
	{
		var header:FlxText = new FlxText(40, y, FlxG.width - 80, text, 12);
		header.setFormat("VCR", 12, FlxColor.YELLOW, LEFT);
		header.scrollFactor.set(0, 0);
		add(header);
	}

	/**
	 * Add performance information displays
	 */
	private function addInfoDisplays():Void
	{
		var yPos:Float = 200;
		
		performanceInfo = new FlxText(40, yPos, FlxG.width - 80, "", 12);
		performanceInfo.setFormat("VCR", 12, FlxColor.CYAN, LEFT);
		performanceInfo.scrollFactor.set(0, 0);
		add(performanceInfo);
		yPos += 60;

		fontInfo = new FlxText(40, yPos, FlxG.width - 80, "", 12);
		fontInfo.setFormat("VCR", 12, FlxColor.GREEN, LEFT);
		fontInfo.scrollFactor.set(0, 0);
		add(fontInfo);
		yPos += 40;

		kernelInfo = new FlxText(40, yPos, FlxG.width - 80, "", 12);
		kernelInfo.setFormat("VCR", 12, FlxColor.ORANGE, LEFT);
		kernelInfo.scrollFactor.set(0, 0);
		add(kernelInfo);

		updateInfoDisplays();
	}

	/**
	 * Update information displays
	 */
	private function updateInfoDisplays():Void
	{
		if (performanceInfo != null && GameKernel != null)
		{
			var stats:Map<String, Dynamic> = GameKernel.getPerformanceStats();
			performanceInfo.text = "PERFORMANCE:\n" +
				"Current FPS: " + stats["currentFPS"] + "\n" +
				"Average FPS: " + Math.round(stats["avgFPS"]) + "\n" +
				"Memory Usage: " + Math.round(stats["currentMemory"]) + " MB\n" +
				"Optimization Level: " + stats["optimizationLevel"];
		}

		if (fontInfo != null)
		{
			var fontStats:Map<String, Int> = FontText.getCacheStats();
			fontInfo.text = "FONT SYSTEM:\n" +
				"Font Caching: " + (ClientPrefs.getPreference('enableFontCaching') ? "Enabled" : "Disabled") + "\n" +
				"Default Font: " + ClientPrefs.getPreference('defaultFont') + "\n" +
				"Cache Entries: " + Lambda.count(fontStats);
		}

		if (kernelInfo != null)
		{
			kernelInfo.text = "KERNEL STATUS:\n" +
				"Auto Optimization: " + (ClientPrefs.getPreference('autoOptimization') ? "Enabled" : "Disabled") + "\n" +
				"Performance Display: " + (ClientPrefs.getPreference('showPerformanceDisplay') ? "Visible" : "Hidden") + "\n" +
				"Target FPS: " + ClientPrefs.getPreference('targetFPS');
		}
	}

	/**
	 * Trigger manual optimization
	 */
	private function triggerManualOptimization():Void
	{
		// Force garbage collection
		GameKernel.triggerGarbageCollection();
		
		// Clear font cache
		FontText.clearFontCache();
		
		// Reset performance history
		GameKernel.resetPerformanceHistory();
		
		// Update info displays
		updateInfoDisplays();
		
		// Show feedback
		var feedback:FlxText = new FlxText(0, 0, FlxG.width, "OPTIMIZATION COMPLETE!", 24);
		feedback.setFormat("VCR", 24, FlxColor.LIME, CENTER);
		feedback.scrollFactor.set(0, 0);
		add(feedback);
		
		// Remove feedback after 2 seconds
		FlxG.cameras.list[0].shake(0.001, 0.2);
		
		trace("Manual optimization triggered");
	}

	/**
	 * Override update to refresh info displays
	 */
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		// Update info displays periodically
		if (FlxG.random.int(0, 100) < 5) // ~5% chance each frame
		{
			updateInfoDisplays();
		}
	}
}