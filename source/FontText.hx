package;

import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import flixel.util.FlxColor;
import openfl.text.TextFormat;

/**
 * Advanced font-based text rendering system to replace sprite-based Alphabet text
 * Supports multiple fonts, better performance, and dynamic text rendering
 */
class FontText extends FlxText
{
	// Font family constants
	public static inline var FONT_ALLER:String = "Aller_rg.ttf";
	public static inline var FONT_CALIBRI:String = "calibri.ttf";
	public static inline var FONT_COMIC:String = "comic.ttf";
	public static inline var FONT_OLD_WINDOWS:String = "old_windows.ttf";
	public static inline var FONT_PIXEL:String = "pixel.otf";
	public static inline var FONT_RIFFIC:String = "riffic.ttf";
	public static inline var FONT_VCR:String = "vcr.ttf";
	
	// Font cache for performance
	private static var fontCache:Map<String, Int> = [];
	
	// Performance settings
	public static var enableFontCaching:Bool = true;
	public static var maxCacheSize:Int = 50;
	
	// Text style cache for faster rendering
	private var styleCache:String = "";
	private var lastFontSize:Float = -1;
	
	public function new(x:Float, y:Float, width:Float, text:String, size:Float = 16, font:String = FONT_VCR, color:FlxColor = FlxColor.WHITE, bold:Bool = false)
	{
		super(x, y, width, text, size);
		
		setFont(font);
		setFormat(font, size, color, LEFT, OUTLINE, FlxColor.BLACK);
		
		// Better text rendering settings
		borderSize = bold ? 2 : 1;
		borderStyle = FlxTextBorderStyle.OUTLINE;
		
		// Performance optimizations
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		// Enable font caching if available
		if (enableFontCaching && fontCache.exists(font))
		{
			fontCache.set(font, fontCache.get(font) + 1);
		}
	}
	
	/**
	 * Set the font with automatic caching
	 */
	public function setFont(fontName:String):Void
	{
		var fontPath:String = "assets/fonts/" + fontName;
		
		// Cache font loading
		if (enableFontCaching)
		{
			if (!fontCache.exists(fontName))
			{
				fontCache.set(fontName, 0);
			}
		}
		
		// Apply font using the proper Flixel method
		#if !html5
		// Native/desktop font loading
		openfl.text.Text.registerFont(openfl.text.Font.loadFromFile(fontPath));
		#end
		
		// Set font family (works for both desktop and web)
		var fontFamily:String = getFontFamilyName(fontName);
		textField.defaultTextFormat = new TextFormat(fontFamily, size, color);
	}
	
	/**
	 * Get font family name from font file
	 */
	private function getFontFamilyName(fontFile:String):String
	{
		return switch (fontFile)
		{
			case FONT_ALLER: return "Aller";
			case FONT_CALIBRI: return "Calibri";
			case FONT_COMIC: return "Comic Sans MS";
			case FONT_OLD_WINDOWS: return "MS Sans Serif";
			case FONT_PIXEL: return "Courier New";
			case FONT_RIFFIC: return "Arial";
			case FONT_VCR: return "Courier New";
			default: return "Arial";
		}
	}
	
	/**
	 * Quick text update without recreation
	 */
	public function setTextFast(newText:String):Void
	{
		if (text != newText)
		{
			text = newText;
		}
	}
	
	/**
	 * Batch text updates for better performance
	 */
	public static function batchTextUpdate(texts:Array<FontText>, content:Array<String>):Void
	{
		if (texts.length != content.length) return;
		
		for (i in 0...texts.length)
		{
			texts[i].setTextFast(content[i]);
		}
	}
	
	override function destroy():Void
	{
		// Clean up font cache
		var fontPath:String = "assets/fonts/" + styleCache;
		if (enableFontCaching && styleCache != "" && fontCache.exists(styleCache))
		{
			var count:Int = fontCache.get(styleCache);
			if (count <= 1)
			{
				fontCache.remove(styleCache);
			}
			else
			{
				fontCache.set(styleCache, count - 1);
			}
		}
		
		super.destroy();
	}
	
	/**
	 * Clear font cache to free memory
	 */
	public static function clearFontCache():Void
	{
		fontCache.clear();
		trace("Font cache cleared");
	}
	
	/**
	 * Get cache statistics
	 */
	public static function getCacheStats():Map<String, Int>
	{
		return fontCache;
	}
}