package;

import Achievements;
import backend.HaxeCommit;
import editors.MasterEditorMenu;
import flixel.effects.FlxFlicker;
import flixel.input.keyboard.FlxKey;
import lime.app.Application;
import FontText;
import OptimizationUtils;
#if FUNNY_ALLOWED
import openfl.display.BlendMode;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
#end

class EnhancedMainMenuState extends MusicBeatState
{
	public static final gitCommit:String = HaxeCommit.getGitCommitHash();

	public static var psychEngineJSVersionNumber:String = '1.49.0-prerelease';
	public static var psychEngineJSVersion:String = psychEngineJSVersionNumber;
	public static var psychEngineVersion:String = '0.6.3';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'donate',
		'options',
		'advanced_debug'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	// Enhanced UI Elements
	var menuContainer:FlxSprite;
	var backgroundParticles:Array<FlxSprite> = [];
	var menuGlow:FlxSprite;
	var performanceIndicator:FontText;
	var themeToggle:FlxSprite;
	var customizationPanel:FlxSprite;
	var isCustomizing:Bool = false;
	
	// Animation variables
	var menuStartTime:Float = 0;
	var screenShakeIntensity:Float = 0;
	var currentTheme:String = "default";
	var waveOffset:Float = 0;
	
	// tips thing
	var tipTextMargin:Float = 10;
	var tipTextScrolling:Bool = false;
	var tipBackground:FlxSprite;
	var tipText:FontText;
	var tipTimer:FlxTimer = new FlxTimer();
	var isTweening:Bool = false;
	var lastString:String = '';

	var tipsArray:Array<String> = [];
	var canDoTips:Bool = true;
	
	var funnycatperson:FlxSprite;

	// Menu customization options
	var themeOptions:Array<String> = ["default", "neon", "retro", "minimal", "dark"];
	var currentThemeIndex:Int = 0;
	var menuAnimations:Array<FlxTween> = [];

	override function create()
	{
		MusicBeatState.windowNameSuffix = " - Enhanced Main Menu";
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Initialize optimization system
		OptimizationUtils.initOptimizationSystem(this);

		tipsArray = CoolUtil.coolTextFile(Paths.txt('funnyTips'));
		if (tipsArray == null){
			canDoTips = false;
			trace('The tips don\'t exist!');
		}
		
		#if FUNNY_ALLOWED
		if ((FlxG.random.bool(1) && DateUtils.date.getHours() == 3))  {
			funnycatperson = new FlxSprite().loadGraphic(Paths.image('catto', 'embed'));
			funnycatperson.setPosition(-60, FlxG.height - funnycatperson.height + 850);
			funnycatperson.scale.set(0.2, 0.2);
			funnycatperson.updateHitbox();
			funnycatperson.moves = false;
			funnycatperson.scrollFactor.set(0, 0);
			funnycatperson.alpha = 0.8;
			FlxG.mouse.visible = true;
		}
		#end

		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		DiscordClient.changePresence("In the Enhanced Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = initPsychCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		FlxG.cameras.add(camAchievement, false);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		// Enhanced background with particles
		createEnhancedBackground();
		
		// Create menu container for better organization
		menuContainer = new FlxSprite();
		menuContainer.screenCenter();
		menuContainer.alpha = 0;
		add(menuContainer);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		if (funnycatperson != null)
			add(funnycatperson);

		// Create enhanced menu items with better animations
		createEnhancedMenuItems();

		// Add performance indicator
		performanceIndicator = new FontText(12, 8, 0, "", 14, FontText.FONT_VCR, FlxColor.WHITE);
		add(performanceIndicator);

		// Add theme customization
		createThemeCustomization();

		FlxG.camera.follow(camFollow, null, 1);

		// Version info with enhanced styling
		var versionContainer:FlxSprite = new FlxSprite(12, FlxG.height - 80);
		versionContainer.makeGraphic(250, 70, 0x80000000);
		versionContainer.alpha = 0.8;
		add(versionContainer);

		var JSVersion:FontText = new FontText(20, FlxG.height - 64, 240, "JS Engine v" + psychEngineJSVersion, 12, FontText.FONT_VCR, FlxColor.WHITE);
		add(JSVersion);
		var PsychVersion:FontText = new FontText(20, FlxG.height - 44, 240, "Psych Engine v" + psychEngineVersion, 12, FontText.FONT_VCR, FlxColor.WHITE);
		add(PsychVersion);
		var FNFVersion:FontText = new FontText(20, FlxG.height - 24, 240, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12, FontText.FONT_VCR, FlxColor.WHITE);
		add(FNFVersion);

		// Enhanced tip system
		tipBackground = new FlxSprite();
		tipBackground.scrollFactor.set();
		tipBackground.alpha = 0.7;
		tipBackground.visible = ClientPrefs.tipTexts;
		add(tipBackground);

		tipText = new FontText(0, 0, 0, "", 20, FontText.FONT_CALIBRI, FlxColor.WHITE);
		tipText.scrollFactor.set();
		tipText.updateHitbox();
		tipText.visible = ClientPrefs.tipTexts;
		add(tipText);

		if (canDoTips)
			tipBackground.makeGraphic(FlxG.width, Std.int((tipTextMargin * 2) + tipText.height), FlxColor.BLACK);
		else if (tipBackground != null){
			tipBackground.destroy();
			tipBackground = null;
		}

		changeItem();
		menuStartTime = FlxG.game.ticks;

		#if ACHIEVEMENTS_ALLOWED
		if (DateUtils.isFunkin())
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		changeItem();
		tipTextStartScrolling();

		// Add entrance animation
		menuContainer.alpha = 1;
		menuItems.forEach(function(item:FlxSprite) {
			item.alpha = 0;
			item.y += 50;
			menuAnimations.push(FlxTween.tween(item, {alpha: 1, y: item.y - 50}, 0.8, {
				ease: FlxEase.backOut,
				delay: optionShit.indexOf(item.animation.curAnim.name) * 0.1
			}));
		});

		super.create();
	}

	function createEnhancedBackground()
	{
		// Create animated background particles
		for (i in 0...15)
		{
			var particle:FlxSprite = new FlxSprite();
			particle.makeGraphic(2, 2);
			particle.color = FlxColor.fromHSB(FlxG.random.int(0, 360), 70, 100);
			particle.x = FlxG.random.int(0, FlxG.width);
			particle.y = FlxG.random.int(0, FlxG.height);
			particle.alpha = FlxG.random.float(0.1, 0.3);
			add(particle);
			backgroundParticles.push(particle);
			
			// Animate particles
			FlxTween.tween(particle, {x: particle.x + FlxG.random.int(-100, 100), y: particle.y + FlxG.random.int(-100, 100)}, FlxG.random.float(8, 15), {
				type: FlxTweenType.PINGPONG
			});
		}

		// Add glowing effect
		menuGlow = new FlxSprite();
		menuGlow.makeGraphic(FlxG.width, FlxG.height);
		menuGlow.alpha = 0;
		menuGlow.blend = BlendMode.ADD;
		add(menuGlow);
	}

	function createEnhancedMenuItems()
	{
		var scale:Float = 1;
		var menuSpacing:Float = 120;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * menuSpacing) + offset);
			
			// Enhanced scaling and positioning
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('hover', optionShit[i] + " white", 12);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			
			// Add hover effects
			menuItem.onHover = function() {
				if (curSelected != menuItem.ID) {
					menuItem.animation.play('hover');
					menuItem.scale.set(1.05, 1.05);
				}
			};
			
			menuItem.onOut = function() {
				if (curSelected != menuItem.ID) {
					menuItem.animation.play('idle');
					menuItem.scale.set(1, 1);
				}
			};
			
			menuItem.updateHitbox();
		}
	}

	function createThemeCustomization()
	{
		themeToggle = new FlxSprite(FlxG.width - 60, 20);
		themeToggle.makeGraphic(40, 40, FlxColor.WHITE);
		themeToggle.alpha = 0.7;
		themeToggle.scrollFactor.set();
		themeToggle.onHover = function() {
			themeToggle.alpha = 1;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		};
		themeToggle.onOut = function() {
			themeToggle.alpha = 0.7;
		};
		themeToggle.onClick = function() {
			toggleCustomizationPanel();
		};
		add(themeToggle);
	}

	function toggleCustomizationPanel()
	{
		if (!isCustomizing) {
			isCustomizing = true;
			customizationPanel = new FlxSprite();
			customizationPanel.makeGraphic(300, 200, 0xE0000000);
			customizationPanel.screenCenter();
			customizationPanel.alpha = 0;
			add(customizationPanel);
			
			FlxTween.tween(customizationPanel, {alpha: 1}, 0.3);
		} else {
			isCustomizing = false;
			FlxTween.tween(customizationPanel, {alpha: 0}, 0.3, {
				onComplete: function() {
					customizationPanel.destroy();
				}
			});
		}
	}

	var selectedSomethin:Bool = false;

	function tipTextStartScrolling()
	{
		if (!canDoTips) return;

		tipText.x = tipTextMargin;
		tipText.y = -tipText.height;

		tipTimer.start(1.0, function(timer:FlxTimer)
		{
			FlxTween.tween(tipText, {y: tipTextMargin}, 0.3);
			tipTimer.start(2.25, function(timer:FlxTimer)
			{
				tipTextScrolling = true;
			});
		});
	}

	override function beatHit()
	{
		if (curBeat % 2 == 0)
		{
			super.beatHit();

			FlxG.camera.zoom += 0.015 * camZoomingMult;
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1000, {ease: FlxEase.quadOut});
		}
	}

	function changeTipText() {
		if (!canDoTips) return;
		var selectedText = tipsArray[FlxG.random.int(0, tipsArray.length - 1)].replace('--', '\n');
		while (selectedText == lastString && tipsArray.length > 1) {
			selectedText = tipsArray[FlxG.random.int(0, tipsArray.length - 1)].replace('--', '\n');
		}

		lastString = selectedText;

		tipText.alpha = 1;
		isTweening = true;
		FlxTween.cancelTweensOf(tipText);
		FlxTween.tween(tipText, {alpha: 0}, 1, {
			ease: FlxEase.linear,
			onComplete: function(freak:FlxTween) {
				tipText.text = selectedText;
				tipText.alpha = 0;

				FlxTween.tween(tipText, {alpha: 1}, 1, {
					ease: FlxEase.linear,
					onComplete: function(freak:FlxTween) {
						isTweening = false;
					}
				});
			}
		});
	}

	override function update(elapsed:Float)
	{
		FlxG.camera.followLerp = 7.5 * (1 + Math.sin(waveOffset) * 0.1);
		waveOffset += elapsed * 0.5;

		// Update performance indicator
		updatePerformanceIndicator();
		
		// Update particle animations
		updateBackgroundParticles(elapsed);

		if (tipTextScrolling)
		{
			tipText.x -= elapsed * 130;
			if (tipText.x < -tipText.width)
			{
				tipTextScrolling = false;
				tipTextStartScrolling();
				changeTipText();
			}
		}

		if (FlxG.sound != null && FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(TitleState.new);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://github.com/terastudio-org/FNF-TS-Engine');
				}
				else if (optionShit[curSelected] == 'advanced_debug')
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new AdvancedDebugMenuState());
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0, scaleX: 0.8, scaleY: 0.8}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										FlxG.switchState(StoryMenuState.new);
									case 'freeplay':
										FlxG.switchState(FreeplayState.new);
									#if MODS_ALLOWED
									case 'mods':
										FlxG.switchState(ModsMenuState.new);
									#end
									#if ACHIEVEMENTS_ALLOWED
									case 'awards':
										LoadingState.loadAndSwitchState(AchievementsMenuState.new);
									#end
									case 'credits':
										FlxG.switchState(CreditsState.new);
									case 'options':
										LoadingState.loadAndSwitchState(options.OptionsState.new);
								}
							});
						}
					});
				}
			}
		#if (desktop)
		else if (FlxG.keys.anyJustPressed(debugKeys)) {
			FlxG.switchState(MasterEditorMenu.new);
		}
		#end
		}
		
		#if FUNNY_ALLOWED
		if (funnycatperson != null && FlxG.mouse.overlaps(funnycatperson) && FlxG.mouse.justPressed){
			final screencap = new FlxSprite(0, 0, FlxScreenGrab.grab().bitmapData);
			screencap.screenCenter(XY);
			screencap.scrollFactor.set(0, 0);
			add(screencap);
			final red:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
			red.screenCenter(XY);
			red.scrollFactor.set(0, 0);
			red.blend = BlendMode.MULTIPLY;
			add(red);
			
			FlxG.sound.music.stop();

			final theCrash = FlxG.sound.play(Paths.sound('crash', 'shared'), 1);
			theCrash.onComplete = function(){
				CoolUtil.showPopUp('YOU JUST MADE AN BIG MISTAKE', 'HELLO');
				openfl.system.System.exit(0);
			}
		}
		#end

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function updatePerformanceIndicator()
	{
		var fps:Int = FlxG.drawFramerate;
		var mem:Float = (cast(openfl.Lib.current.window, dynamic)).session ? 
			((cast(openfl.Lib.current.window, dynamic)).session ? 
			0 : 0) : 0; // Simplified memory check
		
		var performanceLevel:String = "Excellent";
		if (fps < 30) performanceLevel = "Poor";
		else if (fps < 50) performanceLevel = "Fair";
		else if (fps < 75) performanceLevel = "Good";
		
		var perfText:String = 'FPS: $fps | Performance: $performanceLevel';
		if (GameKernel.isInitialized()) {
			perfText += ' | Level: ${GameKernel.getCurrentPerformanceLevel()}';
		}
		
		performanceIndicator.text = perfText;
		
		// Color coding based on performance
		var color:FlxColor = FlxColor.GREEN;
		if (fps < 30) color = FlxColor.RED;
		else if (fps < 50) color = FlxColor.YELLOW;
		else if (fps < 75) color = FlxColor.ORANGE;
		
		performanceIndicator.color = color;
	}

	function updateBackgroundParticles(elapsed:Float)
	{
		for (particle in backgroundParticles)
		{
			if (particle.y < -10) {
				particle.y = FlxG.height + 10;
				particle.x = FlxG.random.int(0, FlxG.width);
			}
			particle.y -= elapsed * 20;
			
			// Add subtle rotation and alpha pulsing
			particle.alpha = 0.1 + 0.2 * Math.sin(FlxG.game.ticks * 0.01);
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
				
				// Enhanced selection animation
				spr.scale.set(1.1, 1.1);
				FlxTween.tween(spr.scale, {x: 1, y: 1}, 0.3, {ease: FlxEase.backOut});
			} else {
				// Reset non-selected items
				spr.scale.set(1, 1);
			}
		});
	}
}