package;

import flixel.FlxState;
import flixel.text.FlxText;

/**
 * Utility class to help integrate the new optimization system
 * Provides backward compatibility and easy setup methods
 */
class OptimizationUtils
{
	/**
	 * Initialize the complete optimization system
	 */
	public static function initOptimizationSystem(?parentState:FlxState):Void
	{
		#if GAME_KERNEL_ENABLED
		// Initialize the game kernel
		GameKernel.init(parentState);
		#end
		
		trace("Optimization system initialized");
	}
	
	/**
	 * Update optimization system (call in your update loop)
	 */
	public static function updateOptimization():Void
	{
		#if GAME_KERNEL_ENABLED
		GameKernel.update();
		#end
	}
	
	/**
	 * Create optimized text with fallback to original Alphabet
	 */
	public static function createOptimizedText(x:Float, y:Float, width:Float, text:String, ?size:Float = 16, ?font:String = FontText.FONT_VCR, ?bold:Bool = false):Dynamic
	{
		#if FONT_TEXT_SYSTEM
		return new FontText(x, y, width, text, size, font, FlxColor.WHITE, bold);
		#else
		return new Alphabet(x, y, text, bold);
		#end
	}
	
	/**
	 * Create optimized menu text with menu behavior
	 */
	public static function createMenuText(x:Float, y:Float, text:String, ?size:Float = 32, ?font:String = FontText.FONT_VCR, ?bold:Bool = true):Dynamic
	{
		#if FONT_TEXT_SYSTEM
		var menuText:OptimizedAlphabet = new OptimizedAlphabet(x, y, text, size, font, bold);
		menuText.isMenuItem = true;
		return menuText;
		#else
		return new Alphabet(x, y, text, bold);
		#end
	}
	
	/**
	 * Batch update multiple text elements efficiently
	 */
	public static function batchUpdateTexts(texts:Array<Dynamic>, contents:Array<String>):Void
	{
		#if FONT_TEXT_SYSTEM
		if (texts.length > 0 && Std.is(texts[0], FontText))
		{
			var fontTexts:Array<FontText> = cast texts;
			FontText.batchTextUpdate(fontTexts, contents);
		}
		else if (texts.length > 0 && Std.is(texts[0], OptimizedAlphabet))
		{
			var alphaTexts:Array<OptimizedAlphabet> = cast texts;
			OptimizedAlphabet.batchUpdateTexts(alphaTexts, contents);
		}
		else
		{
			// Fallback to individual updates
			for (i in 0...texts.length)
			{
				if (i < contents.length && texts[i] != null)
				{
					texts[i].text = contents[i];
				}
			}
		}
		#else
		// Fallback for non-font text system
		for (i in 0...texts.length)
		{
			if (i < contents.length && texts[i] != null)
			{
				texts[i].text = contents[i];
			}
		}
		#end
	}
	
	/**
	 * Get performance statistics safely
	 */
	public static function getPerformanceStats():Map<String, Dynamic>
	{
		#if GAME_KERNEL_ENABLED
		return GameKernel.getPerformanceStats();
		#else
		return [
			"currentFPS" => FlxG.framerate,
			"optimizationLevel" => "disabled",
			"isOptimized" => false
		];
		#end
	}
	
	/**
	 * Set performance level with fallback
	 */
	public static function setPerformanceLevel(level:Dynamic):Void
	{
		#if GAME_KERNEL_ENABLED
		if (Std.is(level, String))
		{
			switch (level)
			{
				case "ultra_low": GameKernel.setPerformanceLevel(GameKernel.PerformanceLevel.ULTRA_LOW);
				case "low": GameKernel.setPerformanceLevel(GameKernel.PerformanceLevel.LOW);
				case "normal": GameKernel.setPerformanceLevel(GameKernel.PerformanceLevel.NORMAL);
				case "high": GameKernel.setPerformanceLevel(GameKernel.PerformanceLevel.HIGH);
				case "ultra_high": GameKernel.setPerformanceLevel(GameKernel.PerformanceLevel.ULTRA_HIGH);
				default: GameKernel.setPerformanceLevel(GameKernel.PerformanceLevel.NORMAL);
			}
		}
		else if (Std.is(level, GameKernel.PerformanceLevel))
		{
			GameKernel.setPerformanceLevel(level);
		}
		#end
	}
	
	/**
	 * Trigger optimization actions with safety checks
	 */
	public static function triggerOptimizationAction(action:String):Bool
	{
		#if GAME_KERNEL_ENABLED
		switch (action.toLowerCase())
		{
			case "gc":
			case "garbage_collect":
				GameKernel.triggerGarbageCollection();
				return true;
			case "reset":
			case "reset_history":
				GameKernel.resetPerformanceHistory();
				return true;
			case "toggle_display":
				GameKernel.togglePerformanceDisplay();
				return true;
			default:
				return false;
		}
		#else
		return false;
		#end
	}
	
	/**
	 * Get font system status
	 */
	public static function getFontSystemStatus():Dynamic
	{
		#if FONT_TEXT_SYSTEM
		return {
			enabled: true,
			cacheStats: FontText.getCacheStats(),
			defaultFont: FontText.FONT_VCR
		};
		#else
		return {
			enabled: false,
			system: "sprite_based"
		};
		#end
	}
	
	/**
	 * Clear font cache with safety check
	 */
	public static function clearFontCache():Void
	{
		#if FONT_TEXT_SYSTEM
		FontText.clearFontCache();
		#end
	}
	
	/**
	 * Get optimization system status
	 */
	public static function getOptimizationStatus():Dynamic
	{
		return {
			fontTextSystem: #if FONT_TEXT_SYSTEM true #else false #end,
			gameKernel: #if GAME_KERNEL_ENABLED true #else false #end,
			enhancedOptimizations: #if ENHANCED_OPTIMIZATIONS true #else false #end,
			autoOptimization: #if AUTO_OPTIMIZATION true #else false #end,
			performanceMonitoring: #if PERFORMANCE_MONITORING true #else false #end
		};
	}
	
	/**
	 * Quick performance check - returns optimization recommendations
	 */
	public static function getOptimizationRecommendations():Array<String>
	{
		var recommendations:Array<String> = [];
		
		var stats = getPerformanceStats();
		var currentFPS:Float = stats["currentFPS"];
		var avgFPS:Float = stats["avgFPS"];
		
		if (avgFPS < 30)
		{
			recommendations.push("Ultra Low performance level recommended");
			recommendations.push("Consider reducing render quality");
		}
		else if (avgFPS < 45)
		{
			recommendations.push("Low performance level recommended");
			recommendations.push("Disable some visual effects");
		}
		else if (avgFPS < 60)
		{
			recommendations.push("Normal performance level is appropriate");
		}
		else
		{
			recommendations.push("High performance mode available");
			recommendations.push("Consider enabling more visual effects");
		}
		
		var memoryUsage:Float = stats["currentMemory"];
		if (memoryUsage > 1000)
		{
			recommendations.push("High memory usage detected - consider triggering garbage collection");
		}
		
		#if !FONT_TEXT_SYSTEM
		recommendations.push("Font Text System is disabled - enable for better performance");
		#end
		
		#if !GAME_KERNEL_ENABLED
		recommendations.push("Game Kernel is disabled - enable for automatic optimization");
		#end
		
		return recommendations;
	}
	
	/**
	 * Safe wrapper for FlxText operations with fallback
	 */
	public static function safeTextSetText(textObject:Dynamic, newText:String):Void
	{
		if (textObject == null) return;
		
		#if FONT_TEXT_SYSTEM
		if (Std.is(textObject, FontText))
		{
			cast(textObject, FontText).setTextFast(newText);
		}
		else if (Std.is(textObject, OptimizedAlphabet))
		{
			cast(textObject, OptimizedAlphabet).text = newText;
		}
		else if (Std.is(textObject, FlxText))
		{
			cast(textObject, FlxText).text = newText;
		}
		else if (Std.is(textObject, Alphabet))
		{
			cast(textObject, Alphabet).text = newText;
		}
		#else
		// Fallback for sprite-based system
		if (Std.is(textObject, Alphabet))
		{
			cast(textObject, Alphabet).text = newText;
		}
		else if (Std.is(textObject, FlxText))
		{
			cast(textObject, FlxText).text = newText;
		}
		#end
	}
	
	/**
	 * Get available font list
	 */
	public static function getAvailableFonts():Array<String>
	{
		#if FONT_TEXT_SYSTEM
		return [
			FontText.FONT_VCR,
			FontText.FONT_ALLER,
			FontText.FONT_CALIBRI,
			FontText.FONT_COMIC,
			FontText.FONT_OLD_WINDOWS,
			FontText.FONT_PIXEL,
			FontText.FONT_RIFFIC
		];
		#else
		return ["Sprite-based system (no fonts)"];
		#end
	}
}