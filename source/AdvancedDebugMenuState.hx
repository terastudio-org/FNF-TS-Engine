package;

import Controls;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import FontText;
import flixel.ui.FlxBar;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import GameKernel;

class AdvancedDebugMenuState extends FlxState
{
	var debugTabs:Array<String> = [
		'Performance',
		'Memory',
		'Game State',
		'Rendering',
		'Physics',
		'Cheats',
		'System'
	];
	
	var currentTab:Int = 0;
	var debugGroups:Map<String, FlxTypedGroup<FlxSprite>> = new Map();
	var currentGroup:FlxTypedGroup<FlxSprite>;
	var tabButtons:Array<FlxSprite> = [];
	var background:FlxSprite;
	var headerText:FontText;
	var infoText:FontText;
	
	// Performance monitoring
	var fpsCounter:FontText;
	var frameTimeCounter:FontText;
	var memoryCounter:FontText;
	var performanceGraph:FlxSprite;
	var frameData:Array<Float> = [];
	
	// Memory tracking
	var memoryBars:Array<FlxBar> = [];
	var memoryData:Dynamic = {};
	
	// Game state inspector
	var stateInspector:FontText;
	var entityList:FlxTypedGroup<FlxSprite>;
	var selectedEntity:Int = 0;
	
	// Rendering debug
	var renderStats:FontText;
	var shaderList:Array<String> = [];
	
	// Physics debug
	var physicsStats:FontText;
	var collisionBoxes:Array<FlxSprite> = [];
	
	// Cheats
	var cheatInput:FlxText;
	var cheatHistory:Array<String> = [];
	var activeCheats:Map<String, Bool> = new Map();
	
	// System info
	var systemInfo:FontText;
	var performanceLevels:Array<String> = ['Ultra Low', 'Low', 'Normal', 'High', 'Ultra High'];
	var currentLevel:Int = 2;
	
	var debugKeys:Array<FlxKey>;
	
	override function create()
	{
		FlxG.mouse.visible = true;
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		
		// Background
		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xE0000000);
		background.scrollFactor.set();
		add(background);
		
		// Initialize debug groups
		for (tab in debugTabs) {
			debugGroups.set(tab, new FlxTypedGroup<FlxSprite>());
		}
		
		// Create UI layout
		createTabInterface();
		createPerformanceTab();
		createMemoryTab();
		createGameStateTab();
		createRenderingTab();
		createPhysicsTab();
		createCheatsTab();
		createSystemTab();
		
		// Add all groups
		for (group in debugGroups) {
			add(group);
			group.visible = false;
		}
		
		// Show initial tab
		currentGroup = debugGroups.get(debugTabs[0]);
		currentGroup.visible = true;
		updateHeaderText();
		
		// Header
		headerText = new FontText(20, 20, FlxG.width - 40, "Advanced Debug Menu", 24, FontText.FONT_VCR, FlxColor.WHITE);
		headerText.scrollFactor.set();
		add(headerText);
		
		// Info text
		infoText = new FontText(20, FlxG.height - 80, FlxG.width - 40, 
			"Controls: TAB to switch tabs | F1: Toggle visibility | F2: Quick cheat | ESC: Exit", 
			12, FontText.FONT_CALIBRI, FlxColor.GRAY);
		infoText.scrollFactor.set();
		add(infoText);
		
		// Initialize performance monitoring
		GameKernel.initialize();
		
		super.create();
	}
	
	function createTabInterface()
	{
		var tabHeight:Float = 50;
		var tabWidth:Float = (FlxG.width - 40) / debugTabs.length;
		
		for (i in 0...debugTabs.length)
		{
			var tabButton:FlxSprite = new FlxSprite(20 + i * tabWidth, 60);
			tabButton.makeGraphic(Std.int(tabWidth - 2), Std.int(tabHeight), FlxColor.DARK_GRAY);
			tabButton.alpha = 0.7;
			tabButton.onHover = function() {
				if (i != currentTab) {
					tabButton.alpha = 1.0;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			};
			tabButton.onOut = function() {
				if (i != currentTab) {
					tabButton.alpha = 0.7;
				}
			};
			tabButton.onClick = function() {
				switchTab(i);
			};
			
			var tabText:FontText = new FontText(tabButton.x + 10, tabButton.y + 15, tabWidth - 20, 
				debugTabs[i], 14, FontText.FONT_CALIBRI, FlxColor.WHITE);
			
			tabButtons.push(tabButton);
			add(tabButton);
			add(tabText);
		}
	}
	
	function createPerformanceTab()
	{
		var group = debugGroups.get('Performance');
		
		// FPS Counter
		fpsCounter = new FontText(40, 140, 300, "FPS: 60", 18, FontText.FONT_VCR, FlxColor.GREEN);
		group.add(fpsCounter);
		
		// Frame Time Counter
		frameTimeCounter = new FontText(40, 170, 300, "Frame Time: 16.67ms", 18, FontText.FONT_VCR, FlxColor.CYAN);
		group.add(frameTimeCounter);
		
		// Memory Counter
		memoryCounter = new FontText(40, 200, 300, "Memory: 0 MB", 18, FontText.FONT_VCR, FlxColor.YELLOW);
		group.add(memoryCounter);
		
		// Performance Graph
		performanceGraph = new FlxSprite(40, 240);
		performanceGraph.makeGraphic(400, 100, FlxColor.BLACK);
		performanceGraph.alpha = 0.8;
		group.add(performanceGraph);
		
		// Performance indicators
		var indicators = [
			"CPU Usage: Loading...",
			"GPU Usage: Loading...",
			"Thread Count: " + Thread.current().id,
			"Optimization Level: " + performanceLevels[currentLevel]
		];
		
		for (i in 0...indicators.length)
		{
			var indicator:FontText = new FontText(40, 370 + i * 25, 300, indicators[i], 14, 
				FontText.FONT_CALIBRI, FlxColor.WHITE);
			group.add(indicator);
		}
	}
	
	function createMemoryTab()
	{
		var group = debugGroups.get('Memory');
		
		var memoryTypes = [
			{ name: "GPU Memory", color: FlxColor.RED },
			{ name: "System Memory", color: FlxColor.BLUE },
			{ name: "Audio Memory", color: FlxColor.GREEN },
			{ name: "Texture Memory", color: FlxColor.YELLOW },
			{ name: "Sprite Memory", color: FlxColor.PURPLE }
		];
		
		for (i in 0...memoryTypes.length)
		{
			var barY = 140 + i * 50;
			var label:FontText = new FontText(40, barY, 200, memoryTypes[i].name, 16, 
				FontText.FONT_CALIBRI, memoryTypes[i].color);
			group.add(label);
			
			var bar:FlxBar = new FlxBar(40, barY + 25, FlxBar.HORIZONTAL, 300, 15, 
				this, memoryTypes[i].name, 0, 100, true);
			bar.color = memoryTypes[i].color;
			group.add(bar);
			memoryBars.push(bar);
		}
		
		var gcButton:FlxButton = new FlxButton(40, 400, "Force GC", function() {
			System.gc();
			FlxG.sound.play(Paths.sound('confirmMenu'));
		});
		group.add(gcButton);
	}
	
	function createGameStateTab()
	{
		var group = debugGroups.get('Game State');
		
		stateInspector = new FontText(40, 140, FlxG.width - 80, "", 14, FontText.FONT_CALIBRI, FlxColor.WHITE);
		group.add(stateInspector);
		
		entityList = new FlxTypedGroup<FlxSprite>();
		group.add(entityList);
		
		// Entity controls
		var prevButton:FlxButton = new FlxButton(40, FlxG.height - 120, "Prev Entity", function() {
			selectedEntity = Math.max(0, selectedEntity - 1);
			updateEntitySelection();
		});
		group.add(prevButton);
		
		var nextButton:FlxButton = new FlxButton(160, FlxG.height - 120, "Next Entity", function() {
			selectedEntity++;
			updateEntitySelection();
		});
		group.add(nextButton);
	}
	
	function createRenderingTab()
	{
		var group = debugGroups.get('Rendering');
		
		renderStats = new FontText(40, 140, FlxG.width - 80, "", 16, FontText.FONT_CALIBRI, FlxColor.WHITE);
		group.add(renderStats);
		
		var shaderControls = [
			"Enable Wireframe Mode",
			"Show Bounding Boxes", 
			"Enable Culling",
			"Disable Blending",
			"Show Normals"
		];
		
		for (i in 0...shaderControls.length)
		{
			var toggle:FlxButton = new FlxButton(40, 200 + i * 40, shaderControls[i], function() {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				// Toggle rendering feature
			});
			group.add(toggle);
		}
	}
	
	function createPhysicsTab()
	{
		var group = debugGroups.get('Physics');
		
		physicsStats = new FontText(40, 140, FlxG.width - 80, "", 16, FontText.FONT_CALIBRI, FlxColor.WHITE);
		group.add(physicsStats);
		
		var debugOptions = [
			"Show Collision Boxes",
			"Show Velocity Vectors",
			"Show Forces",
			"Enable Step-by-step",
			"Pause Physics"
		];
		
		for (i in 0...debugOptions.length)
		{
			var toggle:FlxButton = new FlxButton(40, 200 + i * 40, debugOptions[i], function() {
				FlxG.sound.play(Paths.sound('confirmMenu'));
				// Toggle physics debug feature
			});
			group.add(toggle);
		}
	}
	
	function createCheatsTab()
	{
		var group = debugGroups.get('Cheats');
		
		var cheatLabel:FontText = new FontText(40, 140, 200, "Enter Cheat Code:", 18, FontText.FONT_VCR, FlxColor.WHITE);
		group.add(cheatLabel);
		
		cheatInput = new FlxText(40, 170, 300, "", 16);
		cheatInput.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		group.add(cheatInput);
		
		var submitButton:FlxButton = new FlxButton(350, 170, "Submit", function() {
			executeCheat(cheatInput.text);
		});
		group.add(submitButton);
		
		var quickCheats = [
			"god", "noclip", "speedhack", "moon", "fly", "teleport"
		];
		
		for (i in 0...quickCheats.length)
		{
			var cheatBtn:FlxButton = new FlxButton(40 + i * 60, 220, quickCheats[i], function() {
				executeCheat(quickCheats[i]);
			});
			group.add(cheatBtn);
		}
		
		var activeCheatsText:FontText = new FontText(40, 270, FlxG.width - 80, "Active Cheats: None", 14, 
			FontText.FONT_CALIBRI, FlxColor.YELLOW);
		group.add(activeCheatsText);
	}
	
	function createSystemTab()
	{
		var group = debugGroups.get('System');
		
		systemInfo = new FontText(40, 140, FlxG.width - 80, "", 14, FontText.FONT_CALIBRI, FlxColor.WHITE);
		group.add(systemInfo);
		
		var perfButtons = [];
		for (i in 0...performanceLevels.length)
		{
			var btn:FlxButton = new FlxButton(40 + i * 80, FlxG.height - 100, performanceLevels[i], function() {
				setPerformanceLevel(i);
			});
			perfButtons.push(btn);
			group.add(btn);
		}
		
		// System actions
		var crashButton:FlxButton = new FlxButton(40, FlxG.height - 60, "Test Crash", function() {
			throw new Exception("Manual crash test from debug menu");
		});
		group.add(crashButton);
		
		var restartButton:FlxButton = new FlxButton(160, FlxG.height - 60, "Restart Engine", function() {
			FlxG.resetState();
		});
		group.add(restartButton);
	}
	
	function switchTab(tabIndex:Int)
	{
		if (tabIndex == currentTab) return;
		
		// Update tab button appearance
		tabButtons[currentTab].alpha = 0.7;
		tabButtons[tabIndex].alpha = 1.0;
		
		// Hide current group
		currentGroup.visible = false;
		
		// Show new group
		currentTab = tabIndex;
		currentGroup = debugGroups.get(debugTabs[tabIndex]);
		currentGroup.visible = true;
		
		updateHeaderText();
		FlxG.sound.play(Paths.sound('confirmMenu'));
	}
	
	function updateHeaderText()
	{
		headerText.text = "Advanced Debug Menu - " + debugTabs[currentTab];
	}
	
	function updatePerformanceTab()
	{
		var fps = FlxG.drawFramerate;
		var frameTime = 1000.0 / fps;
		var memory = getMemoryUsage();
		
		fpsCounter.text = "FPS: " + fps;
		fpsCounter.color = fps >= 60 ? FlxColor.GREEN : (fps >= 30 ? FlxColor.YELLOW : FlxColor.RED);
		
		frameTimeCounter.text = "Frame Time: " + frameTime.toFixed(2) + "ms";
		memoryCounter.text = "Memory: " + memory.toFixed(1) + " MB";
		
		// Update performance graph
		frameData.push(fps);
		if (frameData.length > 100) frameData.shift();
		
		// Redraw graph (simplified)
		performanceGraph.makeGraphic(400, 100, FlxColor.BLACK);
	}
	
	function updateMemoryTab()
	{
		var gpuMem = getGPUMemoryUsage();
		var sysMem = getSystemMemoryUsage();
		var audioMem = getAudioMemoryUsage();
		var texMem = getTextureMemoryUsage();
		var spriteMem = getSpriteMemoryUsage();
		
		// Update memory bars (values 0-100)
		if (memoryBars.length >= 5) {
			memoryBars[0].value = gpuMem;
			memoryBars[1].value = sysMem;
			memoryBars[2].value = audioMem;
			memoryBars[3].value = texMem;
			memoryBars[4].value = spriteMem;
		}
	}
	
	function updateGameStateTab()
	{
		var stateInfo = "Current State: " + Type.getClassName(Type.getClass(FlxG.state)) + "\n" +
			"GameObjects: " + getGameObjectCount() + "\n" +
			"Active Tweens: " + FlxTween.numTweens + "\n" +
			"Active Timers: " + FlxTimer.globalTimer.cooldown + "\n" +
			"Cameras: " + FlxG.cameras.list.length + "\n" +
			"Sounds: " + FlxG.sound.list.length;
		
		stateInspector.text = stateInfo;
		updateEntityList();
	}
	
	function updateRenderingTab()
	{
		var renderInfo = "Draw Calls: " + getDrawCalls() + "\n" +
			"Triangles: " + getTriangleCount() + "\n" +
			"Shaders: " + getShaderCount() + "\n" +
			"Render Target: " + getRenderTarget() + "\n" +
			"Post Processing: " + getPostProcessingCount() + "\n" +
			"Blend Mode: " + FlxG.camera.bgColor + " (Current)";
		
		renderStats.text = renderInfo;
	}
	
	function updatePhysicsTab()
	{
		var physicsInfo = "Rigid Bodies: " + getRigidBodyCount() + "\n" +
			"Constraints: " + getConstraintCount() + "\n" +
			"Collision Pairs: " + getCollisionPairs() + "\n" +
			"Physics Timestep: " + FlxG.elapsed + "s\n" +
			"Velocity Iterations: 10\n" +
			"Position Iterations: 10";
		
		physicsStats.text = physicsInfo;
	}
	
	function executeCheat(cheatCode:String)
	{
		cheatCode = cheatCode.toLowerCase().trim();
		cheatHistory.push(cheatCode);
		cheatInput.text = "";
		
		switch (cheatCode)
		{
			case "god":
				activeCheats.set("god", true);
				showCheatFeedback("God Mode: ON");
			case "noclip":
				activeCheats.set("noclip", true);
				showCheatFeedback("No Clip: ON");
			case "speedhack":
				activeCheats.set("speedhack", true);
				FlxG.timeScale = 2.0;
				showCheatFeedback("Speed Hack: ON");
			case "moon":
				activeCheats.set("moon", true);
				FlxG.save.data.gravity = 0.1;
				showCheatFeedback("Low Gravity: ON");
			case "fly":
				activeCheats.set("fly", true);
				showCheatFeedback("Flying Mode: ON");
			case "teleport":
				activeCheats.set("teleport", true);
				showCheatFeedback("Teleport Ready");
			default:
				showCheatFeedback("Unknown Cheat: " + cheatCode);
		}
	}
	
	function showCheatFeedback(message:String)
	{
		var feedback:FlxSprite = new FlxSprite(FlxG.width / 2 - 150, 100);
		feedback.makeGraphic(300, 40, FlxColor.BLACK);
		feedback.alpha = 0.8;
		add(feedback);
		
		var feedbackText:FontText = new FontText(feedback.x + 10, feedback.y + 10, 280, 
			message, 16, FontText.FONT_VCR, FlxColor.YELLOW);
		add(feedbackText);
		
		FlxTween.tween(feedback, {y: 50}, 2, {
			onComplete: function() {
				feedback.destroy();
				feedbackText.destroy();
			}
		});
	}
	
	function setPerformanceLevel(level:Int)
	{
		currentLevel = level;
		switch (level)
		{
			case 0: GameKernel.setPerformanceLevel(GameKernel.ULTRA_LOW);
			case 1: GameKernel.setPerformanceLevel(GameKernel.LOW);
			case 2: GameKernel.setPerformanceLevel(GameKernel.NORMAL);
			case 3: GameKernel.setPerformanceLevel(GameKernel.HIGH);
			case 4: GameKernel.setPerformanceLevel(GameKernel.ULTRA_HIGH);
		}
		showCheatFeedback("Performance Level: " + performanceLevels[level]);
	}
	
	// Placeholder functions for system info
	function getMemoryUsage():Float return 0;
	function getGPUMemoryUsage():Float return 45.2;
	function getSystemMemoryUsage():Float return 67.8;
	function getAudioMemoryUsage():Float return 12.3;
	function getTextureMemoryUsage():Float return 89.1;
	function getSpriteMemoryUsage():Float return 34.5;
	function getGameObjectCount():Int return 150;
	function getDrawCalls():Int return 45;
	function getTriangleCount():Int return 1250;
	function getShaderCount():Int return 3;
	function getRenderTarget():String return "Main Camera";
	function getPostProcessingCount():Int return 2;
	function getRigidBodyCount():Int return 25;
	function getConstraintCount():Int return 8;
	function getCollisionPairs():Int return 12;
	function updateEntityList() {}
	function updateEntitySelection() {}
	
	override function update(elapsed:Float)
	{
		// Update current tab data
		switch (debugTabs[currentTab])
		{
			case 'Performance': updatePerformanceTab();
			case 'Memory': updateMemoryTab();
			case 'Game State': updateGameStateTab();
			case 'Rendering': updateRenderingTab();
			case 'Physics': updatePhysicsTab();
		}
		
		// Handle input
		if (FlxG.keys.justPressed.TAB) {
			currentTab = (currentTab + 1) % debugTabs.length;
			switchTab(currentTab);
		}
		
		if (FlxG.keys.justPressed.F1) {
			visible = !visible;
		}
		
		if (FlxG.keys.justPressed.F2) {
			executeCheat("god");
		}
		
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.switchState(new EnhancedMainMenuState());
		}
		
		// Handle cheat input
		if (FlxG.keys.justPressed.ENTER && cheatInput.hasFocus) {
			executeCheat(cheatInput.text);
		}
		
		super.update(elapsed);
	}
}