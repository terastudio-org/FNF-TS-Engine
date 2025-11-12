package;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.system.FlxAssets;
import flixel.effects.FlxFlicker;

class AdvancedButton extends FlxButton
{
	public var hoverEffect:String = "scale"; // scale, glow, bounce
	public var glowColor:FlxColor = FlxColor.WHITE;
	public var originalScale:FlxPoint;
	
	public function new(X:Float = 0, Y:Float = 0, ?Label:String, ?OnClick:Void->Void)
	{
		super(X, Y, Label, OnClick);
		originalScale = new FlxPoint(scale.x, scale.y);
		setupHoverEffects();
	}
	
	function setupHoverEffects()
	{
		onHover = function() {
			switch (hoverEffect)
			{
				case "scale":
					FlxTween.tween(scale, {x: originalScale.x * 1.1, y: originalScale.y * 1.1}, 0.1);
				case "glow":
					alpha = 1.0;
					FlxFlicker.flicker(this, 0.1, 0.05, true);
				case "bounce":
					FlxTween.tween(y, {y: y - 5}, 0.1, {ease: FlxEase.quadOut, 
						onComplete: function() {
							FlxTween.tween(y, {y: y + 5}, 0.1, {ease: FlxEase.quadIn});
						}
					});
			}
			FlxG.sound.play(Paths.sound('scrollMenu'));
		};
		
		onOut = function() {
			switch (hoverEffect)
			{
				case "scale":
					FlxTween.tween(scale, {x: originalScale.x, y: originalScale.y}, 0.1);
				case "glow":
					alpha = 0.8;
				case "bounce":
					// Already handled in bounce animation
			}
		};
	}
	
	public function setHoverEffect(effect:String)
	{
		hoverEffect = effect;
	}
}

class AnimatedPanel extends FlxSprite
{
	public var animationSpeed:Float = 1.0;
	public var tweenIn:FlxTween;
	public var tweenOut:FlxTween;
	
	public function new(X:Float = 0, Y:Float = 0, Width:Int = 100, Height:Int = 100, Color:FlxColor = FlxColor.BLACK)
	{
		super(X, Y);
		makeGraphic(Width, Height, Color);
		alpha = 0;
	}
	
	public function animateIn(delay:Float = 0)
	{
		alpha = 0;
		y += 20;
		tweenIn = FlxTween.tween(this, {alpha: 0.8, y: y - 20}, 0.3, {
			delay: delay,
			ease: FlxEase.backOut
		});
	}
	
	public function animateOut()
	{
		tweenOut = FlxTween.tween(this, {alpha: 0, y: y + 20}, 0.2, {
			ease: FlxEase.quadIn,
			onComplete: function() {
				destroy();
			}
		});
	}
	
	override function destroy()
	{
		if (tweenIn != null) tweenIn.cancel();
		if (tweenOut != null) tweenOut.cancel();
		super.destroy();
	}
}

class PerformanceMeter extends FlxSprite
{
	private var currentValue:Float = 0;
	private var maxValue:Float = 100;
	private var valueBar:FlxSprite;
	private var label:FontText;
	private var color:FlxColor;
	
	public function new(X:Float, Y:Float, Width:Int = 200, Height:Int = 20, Color:FlxColor = FlxColor.GREEN)
	{
		super(X, Y);
		color = Color;
		makeGraphic(Width, Height, 0x80000000);
		
		valueBar = new FlxSprite(X + 2, Y + 2);
		valueBar.makeGraphic(Width - 4, Height - 4, color);
		add(valueBar);
	}
	
	public function updateValue(Value:Float, MaxValue:Float = 100)
	{
		currentValue = Value;
		maxValue = MaxValue;
		var percentage = Math.min(currentValue / maxValue, 1.0);
		valueBar.scale.x = percentage;
		
		// Color coding based on performance
		if (percentage < 0.3) {
			valueBar.color = FlxColor.RED;
		} else if (percentage < 0.6) {
			valueBar.color = FlxColor.YELLOW;
		} else {
			valueBar.color = color;
		}
	}
	
	public function setLabel(Text:String, FontSize:Int = 12)
	{
		if (label != null) {
			remove(label);
			label.destroy();
		}
		label = new FontText(x + 5, y - 20, 200, Text, FontSize, FontText.FONT_CALIBRI, FlxColor.WHITE);
		add(label);
	}
	
	override function destroy()
	{
		if (label != null) {
			remove(label);
			label.destroy();
		}
		if (valueBar != null) {
			remove(valueBar);
			valueBar.destroy();
		}
		super.destroy();
	}
}

class QuickInfoPanel extends FlxSprite
{
	private var infoText:FontText;
	private var closeButton:FlxSprite;
	
	public function new(X:Float, Y:Float, Width:Int, Height:Int, Info:String = "")
	{
		super(X, Y);
		makeGraphic(Width, Height, 0xE0000000);
		alpha = 0;
		
		infoText = new FontText(x + 10, y + 10, Width - 20, Info, 14, FontText.FONT_CALIBRI, FlxColor.WHITE);
		add(infoText);
		
		closeButton = new FlxSprite(x + Width - 25, y + 5);
		closeButton.makeGraphic(15, 15, FlxColor.RED);
		closeButton.onClick = function() {
			animateOut();
		};
		add(closeButton);
		
		animateIn();
	}
	
	function animateIn()
	{
		alpha = 0;
		y += 20;
		FlxTween.tween(this, {alpha: 0.9, y: y - 20}, 0.3, {ease: FlxEase.backOut});
	}
	
	function animateOut()
	{
		FlxTween.tween(this, {alpha: 0, y: y + 20}, 0.2, {
			ease: FlxEase.quadIn,
			onComplete: function() {
				destroy();
			}
		});
	}
	
	override function destroy()
	{
		if (infoText != null) {
			remove(infoText);
			infoText.destroy();
		}
		if (closeButton != null) {
			remove(closeButton);
			closeButton.destroy();
		}
		super.destroy();
	}
}

class ParticleEmitter extends FlxSprite
{
	private var particles:Array<FlxSprite> = [];
	private var particleCount:Int = 10;
	private var emitterActive:Bool = true;
	
	public function new(X:Float, Y:Float, Count:Int = 10)
	{
		super(X, Y);
		particleCount = Count;
		createParticles();
	}
	
	function createParticles()
	{
		for (i in 0...particleCount)
		{
			var particle:FlxSprite = new FlxSprite();
			particle.makeGraphic(2, 2);
			particle.color = FlxColor.fromHSB(FlxG.random.int(0, 360), 70, 100);
			particle.x = x + FlxG.random.int(-20, 20);
			particle.y = y + FlxG.random.int(-20, 20);
			particle.alpha = FlxG.random.float(0.3, 0.8);
			particles.push(particle);
			add(particle);
			
			startParticleAnimation(particle);
		}
	}
	
	function startParticleAnimation(particle:FlxSprite)
	{
		var duration = FlxG.random.float(2, 5);
		var targetX = particle.x + FlxG.random.int(-50, 50);
		var targetY = particle.y + FlxG.random.int(-50, 50);
		
		FlxTween.tween(particle, {x: targetX, y: targetY, alpha: 0}, duration, {
			type: FlxTweenType.PINGPONG,
			onComplete: function() {
				if (emitterActive) {
					startParticleAnimation(particle);
				}
			}
		});
	}
	
	public function stop()
	{
		emitterActive = false;
		for (particle in particles) {
			FlxTween.cancelTweensOf(particle);
		}
	}
	
	public function start()
	{
		emitterActive = true;
		for (particle in particles) {
			startParticleAnimation(particle);
		}
	}
	
	override function destroy()
	{
		stop();
		for (particle in particles) {
			if (particle != null) {
				remove(particle);
				particle.destroy();
			}
		}
		particles = [];
		super.destroy();
	}
}

class WaveEffect
{
	private var targets:Array<FlxSprite> = [];
	private var waveOffset:Float = 0;
	
	public function new(?Targets:Array<FlxSprite>)
	{
		if (Targets != null) {
			targets = Targets;
		}
	}
	
	public function addTarget(target:FlxSprite)
	{
		targets.push(target);
	}
	
	public function update(elapsed:Float)
	{
		waveOffset += elapsed * 2;
		
		for (i in 0...targets.length)
		{
			var target = targets[i];
			if (target != null) {
				var wave = Math.sin(waveOffset + i * 0.5) * 0.05;
				target.scale.set(1 + wave, 1 + wave);
			}
		}
	}
	
	public function clear()
	{
		targets = [];
	}
}

class UIHelpers
{
	public static function createTooltip(target:FlxSprite, text:String, delay:Float = 1.0)
	{
		var tooltip:QuickInfoPanel = null;
		var timer:Float = 0;
		
		target.onHover = function() {
			// Extend existing hover function if it exists
		};
		
		target.onOut = function() {
			// Extend existing out function if it exists
		};
	}
	
	public static function createProgressBar(x:Float, y:Float, width:Int, height:Int, 
		progress:Float, color:FlxColor = FlxColor.GREEN, label:String = ""):PerformanceMeter
	{
		var bar = new PerformanceMeter(x, y, width, height, color);
		if (label != "") {
			bar.setLabel(label);
		}
		bar.updateValue(progress);
		return bar;
	}
	
	public static function createTabButton(x:Float, y:Float, width:Int, height:Int, 
		text:String, onClick:Void->Void):AdvancedButton
	{
		var button = new AdvancedButton(x, y, text, onClick);
		button.width = width;
		button.height = height;
		button.setHoverEffect("scale");
		return button;
	}
}