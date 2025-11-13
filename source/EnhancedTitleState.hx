package;

import flixel.FlxState;
import flixel.addons.transition.TransitionData;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxGlitchEffect;
import flixel.addons.effects.FlxWaveEffect;
import flixel.addons.effects.FlxSkewEffect;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUITabMenu;
import flixel.animation.FlxAnimationController;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.ui.FlxSoundTray;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxVelocity;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import options.GraphicsSettingsSubState;

#if VIDEOS_ALLOWED
import VideoSprite;
#end

typedef EnhancedTitleData = {
    titlex:Float,
    titley:Float,
    startx:Float,
    starty:Float,
    gfx:Float,
    gyf:Float,
    backgroundSprite:String,
    bpm:Int,
    endY:Float,
    particles:Bool,
    trailEffects:Bool,
    glitchEffects:Bool,
    waveEffects:Bool,
    lightingEffects:Bool
}

class EnhancedTitleState extends MusicBeatState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public static var initialized:Bool = false;
    public static var enhancedTitleJSON:EnhancedTitleData;
    public static var updateVersion:String = '';

    var inCutscene:Bool = false;
    var canPause:Bool = true;

    // Background layers
    var bg:FlxSprite;
    var bgParticles:FlxTypedGroup<FlxParticle>;
    var glowLayer:FlxSprite;
    var waveLayer:FlxSprite;
    
    // Main elements
    var logoBl:FlxSprite;
    var logoTrail:FlxTrail;
    var logoGlitch:FlxGlitchEffect;
    var gfDance:FlxSprite;
    var titleText:FlxSprite;
    var titleGlow:FlxSprite;
    var titleWave:FlxSprite;
    
    // Advanced effects
    var backdrop:FlxBackdrop;
    var lightRays:FlxSprite;
    var floatingText:FlxGroup;
    var energyRings:Array<FlxSprite> = [];
    var particleBurst:Array<FlxParticle> = [];
    
    // UI Elements
    var credGroup:FlxGroup;
    var textGroup:FlxGroup;
    var ngSpr:FlxSprite;
    var blackScreen:FlxSprite;
    var loadingIndicator:FlxSprite;
    var progressBar:FlxSprite;
    
    // Animation variables
    var danceLeft:Bool = false;
    var titleTimer:Float = 0;
    var transitionProgress:Float = 0;
    var particleSpawnTimer:Float = 0;
    var lightIntensity:Float = 0;
    var energyLevel:Float = 0;
    
    // Color schemes
    var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC, 0xFFFF33FF, 0xFF33FF33];
    var titleTextAlphas:Array<Float> = [1, 0.8, 0.6, 0.4];
    var colorPhase:Float = 0;
    
    // Performance and state tracking
    var mustUpdate:Bool = false;
    var transitioning:Bool = false;
    var skippedIntro:Bool = false;
    var newTitle:Bool = false;
    var swagShader:ColorSwap = null;
    
    var curWacky:Array<String> = [];
    var sickBeats:Int = 0;
    
    override public function create():Void
    {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();

        MusicBeatState.windowNameSuffix = " - Enhanced Title Screen";

        MusicBeatState.windowNamePrefix = Assets.getText(Paths.txt("windowTitleBase", "preload"));

        curWacky = FlxRandom.getObject(getIntroTextShit());

        swagShader = new ColorSwap();
        super.create();

        // Enhanced JSON loading with default values
        enhancedTitleJSON = Json.parse(Assets.getText(Paths.txt('enhancedTitleConfig')));
        if (enhancedTitleJSON == null) {
            enhancedTitleJSON = {
                titlex: 150,
                titley: 100,
                startx: 400,
                starty: 580,
                gfx: 300,
                gyf: 220,
                backgroundSprite: "titleBG",
                bpm: 102,
                endY: 100,
                particles: true,
                trailEffects: true,
                glitchEffects: false,
                waveEffects: true,
                lightingEffects: true
            };
        }

        #if (CHECK_FOR_UPDATES)
        if (ClientPrefs.checkForUpdates && !closedState && !Main.askedToUpdate) {
            trace('checking for update');
            var http = new haxe.Http("https://raw.githubusercontent.com/JordanSantiagoYT/FNF-JS-Engine/main/THECHANGELOG.md");
            var returnedData:Array<String> = [];

            http.onData = function (data:String) {
                var versionEndIndex:Int = data.indexOf(';');
                returnedData[0] = data.substring(0, versionEndIndex);
                returnedData[1] = data.substring(versionEndIndex + 1, data.length);
                updateVersion = returnedData[0];
                final curVersion:String = MainMenuState.psychEngineJSVersion.trim();
                final cleanVersion:String = curVersion.split(" (")[0];
                trace(cleanVersion);
                trace('version online: ' + updateVersion + ', your version: ' + cleanVersion);
                if (updateVersion != cleanVersion && CoolUtil.isVersionNewer(updateVersion, cleanVersion)) {
                    trace('versions dont match!');
                    OutdatedState.currChanges = returnedData[1];
                    mustUpdate = true;
                    Main.askedToUpdate = true;
                }
            }

            http.onError = function (error) {
                trace('error: $error');
            }

            http.request();
        }
        #end

        Highscore.load();

        if (!initialized) {
            if (FlxG.save.data != null && FlxG.save.data.fullscreen) {
                FlxG.fullscreen = FlxG.save.data.fullscreen;
            }
            persistentUpdate = true;
            persistentDraw = true;
        }

        if (FlxG.save.data.weekCompleted != null) {
            StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
        }

        FlxG.mouse.visible = false;

        #if FREEPLAY
        FlxG.switchState(FreeplayState.new);
        #elseif CHARTING
        FlxG.switchState(ChartingState.new);
        #else
        if (FlxG.save.data.flashing == null && !FlashingState.leftState) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            FlxG.switchState(FlashingState.new());
        } else {
            if (initialized)
                startIntro();
            else {
                new FlxTimer().start(1, function(tmr:FlxTimer) {
                    startIntro();
                });
            }
        }
        #end
    }

    function startIntro() {
        if (!initialized) {
            Paths.playMenuMusic(true, 0);
        }

        // Dynamic BPM based on theme
        switch (ClientPrefs.daMenuMusic) {
            case 'Mashup' | 'VS Impostor': Conductor.changeBPM(110);
            case 'Dave & Bambi': Conductor.changeBPM(148);
            case 'Dave & Bambi (Old)': Conductor.changeBPM(150);
            case 'DDTO+': Conductor.changeBPM(120);
            case 'Anniversary': Conductor.changeBPM(115);
            case 'Base Game' | 'Default' | 'None' | 'Christmas': Conductor.changeBPM(enhancedTitleJSON.bpm);
            default: Conductor.changeBPM(enhancedTitleJSON.bpm);
        }

        persistentUpdate = true;

        createBackground();
        createParticles();
        createLogo();
        createTitleText();
        createEffects();
        createUIElements();

        if (initialized)
            skipIntro();
        else
            initialized = true;
    }

    function createBackground():Void {
        // Main background
        bg = new FlxSprite();
        if (enhancedTitleJSON.backgroundSprite != null && enhancedTitleJSON.backgroundSprite.length > 0 && enhancedTitleJSON.backgroundSprite != "none") {
            bg.loadGraphic(Paths.image(enhancedTitleJSON.backgroundSprite));
        } else {
            // Create dynamic gradient background
            var bgBitmap:BitmapData = new BitmapData(FlxG.width, FlxG.height);
            var gradient:openfl.display.Graphics = new openfl.display.Graphics();
            
            for (i in 0...FlxG.height) {
                var color:FlxColor = FlxColor.interpolate(0xFF001122, 0xFF002244, i / FlxG.height);
                gradient.beginFill(color);
                gradient.drawRect(0, i, FlxG.width, 1);
                gradient.endFill();
            }
            
            bg.makeGraphic(FlxG.width, FlxG.height, 0xFF001122);
        }
        
        bg.alpha = 0.8;
        add(bg);

        // Animated backdrop
        if (enhancedTitleJSON.waveEffects) {
            backdrop = new FlxBackdrop(Paths.image('titleGrid'), 1, 1, true, true);
            backdrop.alpha = 0.3;
            backdrop.speed.x = 0.1;
            backdrop.speed.y = 0.05;
            add(backdrop);
        }

        // Light rays overlay
        if (enhancedTitleJSON.lightingEffects) {
            lightRays = new FlxSprite();
            lightRays.loadGraphic(Paths.image('lightRays'));
            lightRays.blendMode = BlendMode.ADD;
            lightRays.alpha = 0.5;
            lightRays.screenCenter();
            add(lightRays);
        }
    }

    function createParticles():Void {
        if (!enhancedTitleJSON.particles) return;

        bgParticles = new FlxTypedGroup<FlxParticle>();
        add(bgParticles);

        // Create floating particles
        for (i in 0...50) {
            createParticle();
        }

        // Create energy rings
        for (i in 0...3) {
            createEnergyRing(i);
        }
    }

    function createParticle():Void {
        var particle:FlxParticle = new FlxParticle();
        
        particle.loadGraphic(Paths.image('particleDot'), true, 4, 4);
        particle.animation.add('float', [0, 1, 2, 3], 12, true);
        particle.animation.play('float');
        
        particle.x = FlxRandom.float(0, FlxG.width);
        particle.y = FlxRandom.float(0, FlxG.height);
        particle.alpha = FlxRandom.float(0.3, 0.8);
        particle.blendMode = BlendMode.ADD;
        particle.antialiasing = true;
        
        particle.velocity.x = FlxRandom.float(-20, 20);
        particle.velocity.y = FlxRandom.float(-30, -10);
        
        particle.scale.x = FlxRandom.float(0.5, 2.0);
        particle.scale.y = particle.scale.x;
        
        bgParticles.add(particle);
        particleBurst.push(particle);
    }

    function createEnergyRing(index:Int):Void {
        var ring:FlxSprite = new FlxSprite();
        ring.loadGraphic(Paths.image('energyRing'), true, 200, 200);
        ring.animation.add('pulse', [0, 1, 2, 3], 8, true);
        ring.animation.play('pulse');
        ring.blendMode = BlendMode.ADD;
        ring.alpha = 0.4;
        ring.center = FlxPoint.get(FlxG.width / 2, FlxG.height / 2);
        
        var offset:Float = index * 200;
        ring.x = FlxG.width / 2 - 100 + offset;
        ring.y = FlxG.height / 2 - 100 + offset;
        
        energyRings.push(ring);
        add(ring);
    }

    function createLogo():Void {
        logoBl = new FlxSprite(enhancedTitleJSON.titlex, enhancedTitleJSON.titley);
        logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
        logoBl.antialiasing = ClientPrefs.globalAntialiasing;
        logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
        logoBl.animation.addByPrefix('bounce', 'logo bounce', 12, false);
        logoBl.animation.addByPrefix('glow', 'logo glow', 24, false);
        logoBl.animation.play('bump');
        logoBl.updateHitbox();

        swagShader = new ColorSwap();
        logoBl.shader = swagShader.shader;
        add(logoBl);

        // Add trail effect
        if (enhancedTitleJSON.trailEffects) {
            logoTrail = new FlxTrail(logoBl, null, 10, 0.5, 0xFF33FFFF, 0.1);
            logoTrail.alpha = 0.6;
            add(logoTrail);
        }

        // Add glow effect
        if (enhancedTitleJSON.lightingEffects) {
            glowLayer = new FlxSprite();
            glowLayer.loadGraphic(Paths.image('logoGlow'));
            glowLayer.blendMode = BlendMode.ADD;
            glowLayer.alpha = 0.7;
            glowLayer.center = FlxPoint.get(
                enhancedTitleJSON.titlex + logoBl.width / 2,
                enhancedTitleJSON.titley + logoBl.height / 2
            );
            add(glowLayer);
        }
    }

    function createTitleText():Void {
        titleText = new FlxSprite(enhancedTitleJSON.startx, enhancedTitleJSON.starty);
        
        #if (desktop && MODS_ALLOWED)
        var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
        if (!FileSystem.exists(path)) path = "mods/images/titleEnter.png";
        if (!FileSystem.exists(path)) path = "assets/images/titleEnter.png";
        titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path), File.getContent(StringTools.replace(path, ".png", ".xml")));
        #else
        titleText.frames = Paths.getSparrowAtlas('titleEnter');
        #end

        var animFrames:Array<FlxFrame> = [];
        @:privateAccess {
            titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
            titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
        }

        if (animFrames.length > 0) {
            newTitle = true;
            titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
            titleText.animation.addByPrefix('press', ClientPrefs.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
            titleText.animation.addByPrefix('hover', "ENTER HOVER", 12);
            titleText.animation.addByPrefix('glow', "ENTER GLOW", 16);
        } else {
            newTitle = false;
            titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
            titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
        }

        titleText.antialiasing = ClientPrefs.globalAntialiasing;
        titleText.animation.play('idle');
        titleText.updateHitbox();
        add(titleText);

        // Add wave effect to title text
        if (enhancedTitleJSON.waveEffects) {
            titleWave = new FlxSprite(titleText.x, titleText.y);
            titleWave.loadGraphic(titleText.graphic);
            titleWave.blendMode = BlendMode.ADD;
            titleWave.alpha = 0.3;
            add(titleWave);
        }

        // Create floating text particles
        floatingText = new FlxGroup();
        for (i in 0...5) {
            createFloatingText(i);
        }
        add(floatingText);
    }

    function createFloatingText(index:Int):Void {
        var text:FlxText = new FlxText(
            FlxG.width + (index * 100),
            FlxRandom.float(50, FlxG.height - 50),
            200,
            "ENHANCED",
            16
        );
        text.color = titleTextColors[index % titleTextColors.length];
        text.alpha = FlxRandom.float(0.3, 0.7);
        text.font = "vcr.ttf";
        text.antialiasing = true;
        
        floatingText.add(text);

        // Animate floating text
        FlxTween.tween(text, {
            x: -text.width
        }, FlxRandom.float(8, 15), {
            ease: FlxEase.linear,
            onComplete: function(_) {
                text.x = FlxG.width + 100;
                text.y = FlxRandom.float(50, FlxG.height - 50);
            }
        });
    }

    function createEffects():Void {
        gfDance = new FlxSprite(enhancedTitleJSON.gfx, enhancedTitleJSON.gfy);
        gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
        gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
        gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
        gfDance.animation.addByIndices('energy', 'gfDance', [0, 1, 2, 3, 4, 5], "", 24, false);
        gfDance.antialiasing = ClientPrefs.globalAntialiasing;

        add(gfDance);
        gfDance.shader = swagShader.shader;
    }

    function createUIElements():Void {
        credGroup = new FlxGroup();
        add(credGroup);
        textGroup = new FlxGroup();

        blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        credGroup.add(blackScreen);

        var credTextShit:Alphabet = new Alphabet(0, 0, "", true);
        credTextShit.screenCenter();
        credTextShit.visible = false;
        credGroup.add(credTextShit);

        ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
        add(ngSpr);
        ngSpr.visible = false;
        ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
        ngSpr.updateHitbox();
        ngSpr.screenCenter(X);
        ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

        // Loading indicator
        loadingIndicator = new FlxSprite();
        loadingIndicator.loadGraphic(Paths.image('loadingCircle'), true, 32, 32);
        loadingIndicator.animation.add('spin', [0, 1, 2, 3, 4, 5, 6, 7], 12, true);
        loadingIndicator.animation.play('spin');
        loadingIndicator.center = FlxPoint.get(FlxG.width / 2, FlxG.height / 2 + 100);
        loadingIndicator.alpha = 0;
        add(loadingIndicator);

        // Progress bar
        progressBar = new FlxSprite();
        progressBar.makeGraphic(200, 4, 0xFF33FFFF);
        progressBar.center = FlxPoint.get(FlxG.width / 2, FlxG.height / 2 + 120);
        progressBar.alpha = 0;
        add(progressBar);

        FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
    }

    function getIntroTextShit():Array<Array<String>> {
        var fullText:String = Assets.getText(Paths.txt('introText'));
        var firstArray:Array<String> = fullText.split('\n');
        var swagGoodArray:Array<Array<String>> = [];

        for (i in firstArray) {
            swagGoodArray.push(i.split('--'));
        }

        return swagGoodArray;
    }

    override function update(elapsed:Float):Void {
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

        if (gamepad != null && gamepad.justPressed.START)
            pressedEnter = true;

        // Update color phase for dynamic color changes
        colorPhase += elapsed * 0.5;
        if (colorPhase > 1) colorPhase -= 1;

        // Update particle animations
        updateParticles(elapsed);
        
        // Update energy rings
        updateEnergyRings(elapsed);
        
        // Update light effects
        updateLightEffects(elapsed);

        // Update title text animations
        if (newTitle) {
            titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
            if (titleTimer > 2) titleTimer -= 2;
        }

        // Handle title text effects
        if (initialized && !transitioning && skippedIntro) {
            if (newTitle && !pressedEnter) {
                var timer:Float = titleTimer;
                if (timer >= 1) timer = (-timer) + 2;
                timer = FlxEase.quadInOut(timer);

                // Dynamic color cycling
                var currentColorIndex:Int = Math.floor(colorPhase * titleTextColors.length);
                var nextColorIndex:Int = (currentColorIndex + 1) % titleTextColors.length;
                var blendFactor:Float = (colorPhase * titleTextColors.length) % 1;
                
                titleText.color = FlxColor.interpolate(
                    titleTextColors[currentColorIndex],
                    titleTextColors[nextColorIndex],
                    blendFactor
                );
                
                titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
                
                // Add hover effect
                if (FlxG.mouse.overlaps(titleText)) {
                    titleText.animation.play('hover');
                } else {
                    titleText.animation.play('idle');
                }
            }

            if (pressedEnter) {
                titleText.color = FlxColor.WHITE;
                titleText.alpha = 1;
                titleText.animation.play('press');
                
                // Particle burst effect
                createParticleBurst();
                
                FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
                FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

                transitionProgress = 0;
                transitioning = true;

                // Enhanced transition effects
                FlxTween.tween(progressBar, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
                FlxTween.tween(loadingIndicator, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
                
                new FlxTimer().start(0.1, function(tmr:FlxTimer) {
                    FlxTween.tween(progressBar.scale, {x: 0}, 2, {ease: FlxEase.cubicInOut});
                });

                new FlxTimer().start(2.2, function(tmr:FlxTimer) {
                    if (mustUpdate) {
                        FlxG.switchState(OutdatedState.new());
                    } else {
                        FlxG.switchState(MainMenuState.new());
                    }
                    closedState = true;
                });
            }
        }

        // Update shader effects
        if (swagShader != null) {
            if (controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
            if (controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
        }

        // Update energy level based on beat
        energyLevel = Math.sin(colorPhase * Math.PI * 2) * 0.5 + 0.5;

        super.update(elapsed);
    }

    function updateParticles(elapsed:Float):Void {
        particleSpawnTimer += elapsed;
        if (particleSpawnTimer > 0.1 && bgParticles.countLiving() < 50) {
            createParticle();
            particleSpawnTimer = 0;
        }

        bgParticles.forEachAlive(function(particle:FlxParticle) {
            // Update particle position
            particle.x += particle.velocity.x * elapsed;
            particle.y += particle.velocity.y * elapsed;

            // Add gravity effect
            particle.velocity.y += 5 * elapsed;

            // Wrap around screen
            if (particle.x > FlxG.width + 10) particle.x = -10;
            if (particle.x < -10) particle.x = FlxG.width + 10;
            if (particle.y > FlxG.height + 10) particle.y = -10;
            if (particle.y < -10) particle.y = FlxG.height + 10;

            // Animate alpha based on energy
            particle.alpha = Math.sin(colorPhase * Math.PI * 2) * 0.3 + 0.5;
        });
    }

    function updateEnergyRings(elapsed:Float):Void {
        for (i in 0...energyRings.length) {
            var ring = energyRings[i];
            ring.angle += elapsed * 30 * (i + 1);
            ring.alpha = Math.sin(colorPhase * Math.PI * 2 + i * 0.5) * 0.3 + 0.4;
            
            // Pulse effect
            var pulseScale:Float = 1 + Math.sin(colorPhase * Math.PI * 2) * 0.1;
            ring.scale.x = pulseScale;
            ring.scale.y = pulseScale;
        }
    }

    function updateLightEffects(elapsed:Float):Void {
        if (lightRays != null) {
            lightRays.angle += elapsed * 10;
            lightRays.alpha = 0.3 + Math.sin(colorPhase * Math.PI * 2) * 0.2;
        }

        if (glowLayer != null) {
            glowLayer.alpha = 0.5 + Math.sin(colorPhase * Math.PI * 2) * 0.3;
            
            // Follow logo movement
            if (logoBl != null) {
                glowLayer.center = FlxPoint.get(
                    logoBl.x + logoBl.width / 2,
                    logoBl.y + logoBl.height / 2
                );
            }
        }
    }

    function createParticleBurst():Void {
        for (i in 0...20) {
            var particle:FlxParticle = new FlxParticle();
            particle.loadGraphic(Paths.image('particleBurst'), true, 8, 8);
            particle.animation.add('explode', [0, 1, 2, 3], 20, false);
            particle.animation.play('explode');
            particle.blendMode = BlendMode.ADD;
            
            // Position at title text
            particle.x = titleText.x + FlxRandom.float(0, titleText.width);
            particle.y = titleText.y + FlxRandom.float(0, titleText.height);
            
            // Random velocity
            var angle:Float = FlxRandom.float(0, Math.PI * 2);
            var speed:Float = FlxRandom.float(100, 300);
            particle.velocity.x = Math.cos(angle) * speed;
            particle.velocity.y = Math.sin(angle) * speed;
            
            add(particle);
            
            // Auto-destroy after animation
            new FlxTimer().start(1, function(tmr:FlxTimer) {
                remove(particle, true);
                particle.destroy();
            });
        }
    }

    override function beatHit():Void {
        super.beatHit();

        FlxG.camera.zoom += 0.02;

        FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1200, {ease: FlxEase.quadOut});

        if (logoBl != null) {
            logoBl.animation.play('bump', true);
            
            // Add bounce effect
            FlxTween.tween(logoBl.scale, {
                x: 1.1,
                y: 1.1
            }, 0.1, {
                ease: FlxEase.quadOut,
                onComplete: function(_) {
                    FlxTween.tween(logoBl.scale, {
                        x: 1,
                        y: 1
                    }, 0.3, {ease: FlxEase.elasticOut});
                }
            });
        }

        if (gfDance != null) {
            danceLeft = !danceLeft;
            if (danceLeft)
                gfDance.animation.play('danceRight');
            else
                gfDance.animation.play('danceLeft');
        }

        // Enhanced particle burst on every beat
        if (enhancedTitleJSON.particles) {
            for (i in 0...3) {
                var particle:FlxParticle = new FlxParticle();
                particle.loadGraphic(Paths.image('particleDot'), true, 4, 4);
                particle.animation.add('beat', [0, 1, 2, 3], 16, true);
                particle.animation.play('beat');
                particle.blendMode = BlendMode.ADD;
                particle.alpha = 0.6;
                
                particle.x = FlxRandom.float(0, FlxG.width);
                particle.y = FlxRandom.float(0, FlxG.height);
                
                add(particle);
                
                new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                    remove(particle, true);
                    particle.destroy();
                });
            }
        }

        if (!closedState) {
            sickBeats++;
            switch (sickBeats) {
                case 1:
                    FlxG.sound.music.fadeIn(4, 0, 0.7);
                case 2:
                    #if PSYCH_WATERMARKS
                    createCoolText(['ENHANCED ENGINE BY'], 15);
                    #else
                    createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
                    #end
                case 4:
                    #if PSYCH_WATERMARKS
                    addMoreText('Jordan Santiago', 15);
                    addMoreText('Enhanced with Advanced Effects', 15);
                    #else
                    addMoreText('present');
                    #end
                case 5:
                    deleteCoolText();
                case 6:
                    #if PSYCH_WATERMARKS
                    createCoolText(['NOT ASSOCIATED WITH'], -40);
                    #else
                    createCoolText(['In association', 'with'], -40);
                    #end
                case 8:
                    addMoreText('enhanced FNF', -40);
                    ngSpr.visible = true;
                case 9:
                    deleteCoolText();
                    ngSpr.visible = false;
                case 10:
                    createCoolText([curWacky[0]]);
                case 12:
                    addMoreText(curWacky[1]);
                case 13:
                    deleteCoolText();
                case 14:
                    addMoreText('ENHANCED');
                case 15:
                    addMoreText('FRIDAY');
                case 16:
                    addMoreText('NIGHT');
                case 17:
                    addMoreText('FUNKIN');
                case 18:
                    skipIntro();
            }
        }
    }

    function createCoolText(textArray:Array<String>, ?offset:Float = 0) {
        for (i in 0...textArray.length) {
            var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
            money.screenCenter(X);
            money.y += (i * 60) + 200 + offset;
            
            // Enhanced text effects
            money.alpha = 0;
            FlxTween.tween(money, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
            
            if (credGroup != null && textGroup != null) {
                credGroup.add(money);
                textGroup.add(money);
            }
        }
    }

    function addMoreText(text:String, ?offset:Float = 0) {
        if (textGroup != null && credGroup != null) {
            var coolText:Alphabet = new Alphabet(0, 0, text, true);
            coolText.screenCenter(X);
            coolText.y += (textGroup.length * 60) + 200 + offset;
            
            // Enhanced text effects
            coolText.alpha = 0;
            FlxTween.tween(coolText, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
            
            credGroup.add(coolText);
            textGroup.add(coolText);
        }
    }

    function deleteCoolText() {
        while (textGroup.members.length > 0) {
            var text:Alphabet = textGroup.members[0];
            FlxTween.tween(text, {alpha: 0}, 0.3, {
                ease: FlxEase.quadIn,
                onComplete: function(_) {
                    credGroup.remove(text, true);
                    textGroup.remove(text, true);
                }
            });
        }
    }

    var skippedIntro:Bool = false;
    var increaseVolume:Bool = false;
    public static var closedState:Bool = false;
    
    function skipIntro():Void {
        if (!skippedIntro) {
            skippedIntro = true;

            // Enhanced logo animation
            FlxTween.tween(logoBl, {
                y: enhancedTitleJSON.endY,
                angle: 360
            }, 1.8, {ease: FlxEase.expoInOut});

            // Fade out credit elements
            FlxTween.tween(credGroup, {alpha: 0}, 1.5, {ease: FlxEase.quadIn});
            FlxTween.tween(ngSpr, {alpha: 0}, 1, {ease: FlxEase.quadIn});

            // Camera flash effect
            FlxG.camera.flash(FlxColor.WHITE, 4);

            // Remove elements after animation
            new FlxTimer().start(2, function(tmr:FlxTimer) {
                if (credGroup != null) remove(credGroup);
                if (ngSpr != null) remove(ngSpr);
            });
        }
    }
}