package;

/**
 * Optimized Font-based Alphabet system
 * Replaces the inefficient sprite-based Alphabet with font-based rendering
 */
class OptimizedAlphabet extends FontText
{
	public var letters:Array<FontText> = [];
	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	public var changeX:Bool = true;
	public var changeY:Bool = true;
	public var distancePerItem:Float = 20;
	public var startPosition:Float = 0;
	
	// Word wrapping settings
	public var maxWidth:Float = 600;
	public var lineSpacing:Float = 20;
	
	// Performance optimizations
	private var needLayoutUpdate:Bool = true;
	private var cachedLines:Array<String> = [];
	
	public function new(x:Float, y:Float, text:String = "", ?size:Float = 32, ?font:String = FontText.FONT_VCR, ?bold:Bool = true)
	{
		super(x, y, 1000, "", size, font, FlxColor.WHITE, bold); // Width doesn't matter for this system
		this.bold = bold;
		this.text = text;
		
		// Don't render this text directly - we render individual letters
		visible = false;
		
		// Set up menu item behavior
		this.isMenuItem = false;
	}
	
	/**
	 * Set text and update letters (batch operation for better performance)
	 */
	public override function set_text(newText:String)
	{
		if (text == newText) return newText;
		
		// Clear existing letters
		clearLetters();
		
		// Create new letters
		createLetters(newText);
		
		needLayoutUpdate = true;
		return super.set_text(newText);
	}
	
	/**
	 * Create font-based letters instead of sprites
	 */
	private function createLetters(text:String):Void
	{
		var lines:Array<String> = text.split('\n');
		cachedLines = lines;
		
		var yOffset:Float = 0;
		
		for (line in lines)
		{
			var xOffset:Float = 0;
			var chars:Array<String> = line.split('');
			
			for (char in chars)
			{
				if (char != ' ' && char != '_')
				{
					var letter:FontText = new FontText(
						x + xOffset, 
						y + yOffset, 
						50, // Width for single character
						char, 
						(size != null ? size : 32), 
						font, 
						color, 
						bold
					);
					
					// Copy our properties
					letter.antialiasing = this.antialiasing;
					letter.visible = this.visible;
					letter.alpha = this.alpha;
					letter.scrollFactor.copyFrom(this.scrollFactor);
					
					add(letter);
					letters.push(letter);
					
					// Calculate next position (approximate character width)
					xOffset += getCharacterWidth(char);
				}
				else
				{
					// Space character
					xOffset += getCharacterWidth(' ');
				}
			}
			
			yOffset += lineSpacing + (size != null ? size : 32);
		}
		
		needLayoutUpdate = false;
	}
	
	/**
	 * Get approximate character width for positioning
	 */
	private function getCharacterWidth(char:String):Float
	{
		// Approximate widths based on character type
		var baseWidth:Float = (size != null ? size : 32) * 0.6;
		
		return switch (char.toLowerCase())
		{
			case 'i', 'l', '1': baseWidth * 0.5;
			case 'w', 'm': baseWidth * 1.2;
			case 't': baseWidth * 0.7;
			default: baseWidth;
		}
	}
	
	/**
	 * Clear all letters
	 */
	public function clearLetters():Void
	{
		for (letter in letters)
		{
			if (letter != null)
			{
				letter.destroy();
			}
		}
		letters = [];
		cachedLines = [];
	}
	
	/**
	 * Update letter positions (faster than recreating)
	 */
	public function updateLetterPositions():Void
	{
		if (!needLayoutUpdate && letters.length == 0) return;
		
		clearLetters();
		createLetters(text);
	}
	
	/**
	 * Set scaling for all letters
	 */
	public function setScale(newX:Float, newY:Null<Float> = null):Void
	{
		if (newY == null) newY = newX;
		
		for (letter in letters)
		{
			if (letter != null)
			{
				letter.scale.x = newX;
				letter.scale.y = newY;
			}
		}
		
		// Update positioning based on new scale
		needLayoutUpdate = true;
	}
	
	/**
	 * Set alignment for all letters
	 */
	public function setAlignment(alignment:Alignment):Void
	{
		// This is a simplified alignment - full implementation would be more complex
		var totalWidth:Float = getTotalWidth();
		var xOffset:Float = 0;
		
		switch (alignment)
		{
			case CENTERED:
				xOffset = (maxWidth - totalWidth) / 2;
			case RIGHT:
				xOffset = maxWidth - totalWidth;
			default:
				xOffset = 0;
		}
		
		for (letter in letters)
		{
			if (letter != null)
			{
				letter.x += xOffset;
			}
		}
	}
	
	/**
	 * Get total width of all letters
	 */
	private function getTotalWidth():Float
	{
		if (letters.length == 0) return 0;
		
		var maxWidth:Float = 0;
		var currentLineWidth:Float = 0;
		
		var currentLine:Int = 0;
		for (letter in letters)
		{
			if (letter != null)
			{
				// Simple line break detection (rough approximation)
				if (currentLineWidth == 0)
				{
					currentLine++;
				}
				
				currentLineWidth += letter.width;
				
				if (currentLineWidth > maxWidth)
				{
					maxWidth = currentLineWidth;
				}
			}
		}
		
		return maxWidth;
	}
	
	/**
	 * Enhanced update method for menu behavior
	 */
	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var lerpVal:Float = Math.exp(-elapsed * 9.6);
			if (changeX)
			{
				x = FlxMath.lerp((targetY * distancePerItem) + startPosition, x, lerpVal);
			}
			if (changeY)
			{
				y = FlxMath.lerp((targetY * distancePerItem * 1.3) + startPosition, y, lerpVal);
			}
		}
		
		// Update letter positions if needed
		if (needLayoutUpdate)
		{
			updateLetterPositions();
		}
		
		super.update(elapsed);
	}
	
	/**
	 * Snap to position (for menu items)
	 */
	public function snapToPosition():Void
	{
		if (isMenuItem)
		{
			if (changeX)
			{
				x = (targetY * distancePerItem) + startPosition;
			}
			if (changeY)
			{
				y = (targetY * distancePerItem * 1.3) + startPosition;
			}
		}
	}
	
	/**
	 * Batch update text for multiple instances (performance optimization)
	 */
	public static function batchUpdateTexts(texts:Array<OptimizedAlphabet>, newTexts:Array<String>):Void
	{
		if (texts.length != newTexts.length) return;
		
		for (i in 0...texts.length)
		{
			texts[i].set_text(newTexts[i]);
		}
	}
	
	/**
	 * Set visibility for all letters
	 */
	override function set_visible(value:Bool):Bool
	{
		for (letter in letters)
		{
			if (letter != null)
			{
				letter.visible = value;
			}
		}
		
		return super.set_visible(value);
	}
	
	/**
	 * Set alpha for all letters
	 */
	override function set_alpha(value:Float):Float
	{
		for (letter in letters)
		{
			if (letter != null)
			{
				letter.alpha = value;
			}
		}
		
		return super.set_alpha(value);
	}
	
	/**
	 * Destroy all letters when this object is destroyed
	 */
	override function destroy():Void
	{
		clearLetters();
		super.destroy();
	}
	
	/**
	 * Get performance statistics
	 */
	public function getPerformanceStats():Dynamic
	{
		return {
			letterCount: letters.length,
			visibleLetters: letters.filter(l -> l != null && l.visible).length,
			totalWidth: getTotalWidth(),
			lines: cachedLines.length
		};
	}
}

// Alignment enum for compatibility with original Alphabet
enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}