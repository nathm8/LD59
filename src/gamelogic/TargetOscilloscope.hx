package gamelogic;

import graphics.WaveformGraphics;
import sound.SoundManager;
import graphics.VolumeSlider;
import sound.CustomSound;
import slide.Tween;
import utilities.Utilities.clamp;
import utilities.Vector2D;
import h2d.col.Circle;
import haxe.Json;
import hxd.fs.FileEntry;
import hxd.Event;
import hxd.Res;
import h2d.Interactive;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Object;
import h2d.filter.Blur;
import h2d.filter.Glow;
import h2d.filter.Group;
import gamelogic.Waveform.WaveformInverter;
import gamelogic.Waveform.Triangle;
import gamelogic.Waveform.WaveformCombination;
import gamelogic.Waveform.Square;
import gamelogic.Waveform.Sine;
import utilities.Utilities.colors;
import utilities.RNGManager;
import utilities.MessageManager;
import graphics.Handle;

var targets = new Array<Waveform>();

class TargetSwitch extends Object implements MessageListener {

    public var startPos = new Vector2D();
    public var endPos = new Vector2D();
    public var switchMaxLag = 0.0;
    var tweenParam = 0.0;
    var tween: Tween;
    
    var switchReady: Bitmap;
    var switchReadyMid: Bitmap;
    var switchReadyBot: Bitmap;
    var switchFlipped: Bitmap;
    var callback: Void -> Void;
    
    var isSelected = false;
    
    public function new(c: Void -> Void, ?p: Object) {
        super(p);
        
        callback = c;
        
        switchReadyBot = new Bitmap(Res.img.SwitchBottom.toTile().center(), this);
        switchReadyMid = new Bitmap(Res.img.SwitchMiddle.toTile().center(), this);
        switchReady = new Bitmap(Res.img.SwitchTop.toTile().center(), this);
        
        var i = new Interactive(0, 0, switchReady, new Circle(0, 0, 22));
        i.onPush = (e: Event) -> {
            isSelected = true;
        };
        i.onRelease = (e: Event) -> {
            if (switchReady.x != endPos.x)
                reset();
            isSelected = false;
        };

        switchFlipped = new Bitmap(Res.img.SwitchOff.toTile().center(), this);
        switchFlipped.visible = false;
        switchFlipped.x = endPos.x;
        switchFlipped.y = endPos.y;

        MessageManager.addListener(this);
    }

    // r in [0, 1] ratio between startPos and endPos, 1 = startPos
    function setActiveSpritesPositions(r: Float, update_tween_param=true) {
        switchReady.x = r*startPos.x + (1-r)*endPos.x;
        switchReady.x = clamp(switchReady.x, startPos.x, endPos.x);

        if (update_tween_param) tweenParam = r;
        r = r == 0.5 ? 0 : (r-0.5)/0.5;
        switchReadyMid.x = switchReady.x + 0.5*r*switchMaxLag;
        switchReadyBot.x = switchReady.x + r*switchMaxLag;
    }

    public function receive(msg: Message): Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            var start_abs = localToGlobal(startPos);
            var end_abs = localToGlobal(endPos);
            
            var mouse_x = params.scenePosition.x;
            var x_diff = mouse_x - start_abs.x;

            var r = x_diff/(end_abs.x - start_abs.x);

            // TODO proper physical spring simulation
            var m: Float;
            if (r <= 0.0)
                m = 1.0;
            else if (r < 0.5)
                m = 15*Math.pow(-r, 5) + 1
            else if (r < 1)
                m = 15*Math.pow(-r + 0.5, 5) + 0.5;
            else
                m = 0;
        
            setActiveSpritesPositions(m);
            if (switchReady.x == endPos.x) {
                isSelected = false;
                callback();
                switchReady.visible = false;
                switchReadyMid.visible = false;
                switchReadyBot.visible = false;
                switchFlipped.visible = true;
            }
        }
        return false;
    }

    public function reset() {
        tween?.stop();
        tween = Main.tweenManager.animateTo(this, { tweenParam: 1}, 0.1)
            .onUpdate(() -> setActiveSpritesPositions(tweenParam, false)
            );
        tween.start();
        switchReady.visible = true;
        switchReadyMid.visible = true;
        switchReadyBot.visible = true;
        switchFlipped.visible = false;
    }

    // this won't play nice if it's called while mouse movement is happening, but it's debug only so that's not a problem
    public function updateGraphics() {
        switchReadyBot.y = startPos.y;
        switchReadyMid.y = startPos.y;
        switchReady.y = startPos.y;
        switchFlipped.x = endPos.x;
        switchFlipped.y = endPos.y;
        setActiveSpritesPositions(1);
    }
}

typedef TargetJson = {
    var inputWaveformGraphicsWidth: Int;
    var inputWaveformGraphicsHeight: Int;
    var inputWaveformGraphicsX: Float;
    var inputWaveformGraphicsY: Float;
    var targetWaveformGraphicsWidth: Int;
    var targetWaveformGraphicsHeight: Int;
    var targetWaveformGraphicsX: Float;
    var targetWaveformGraphicsY: Float;
    var combinedWaveformGraphicsWidth: Int;
    var combinedWaveformGraphicsHeight: Int;
    var combinedWaveformGraphicsX: Float;
    var combinedWaveformGraphicsY: Float;

    var portX: Float;
    var portY: Float;

    var handleX: Float;
    var handleY: Float;

    var lightOneX: Float;
    var lightOneY: Float;
    var lightTwoX: Float;
    var lightTwoY: Float;
    var lightThreeX: Float;
    var lightThreeY: Float;

    var switchStartX: Float;
    var switchStartY: Float;
    var switchEndX: Float;
    var switchEndY: Float;
    var switchMaxLag: Float;

    var sliderOneX: Float;
    var sliderOneY: Float;
    var sliderTwoX: Float;
    var sliderTwoY: Float;
}

class TargetOscilloscope extends Object implements Updateable
                                        implements MessageListener {
    
    var sprite: Bitmap;

    var params: TargetJson;
    
    var puzzlesComplete = 0;

    var lightOne: Bitmap;
    var lightTwo: Bitmap;
    var lightThree: Bitmap;
    var glowOne: Bitmap;
    var glowTwo: Bitmap;
    var glowThree: Bitmap;

    public var inputWaveform: Waveform;
    var targetWaveform: Waveform;

    var inputWaveformGraphics: WaveformGraphics;
    var targetWaveformGraphics: WaveformGraphics;
    var combinedWaveformGraphicsOne: WaveformGraphics;
    var combinedWaveformGraphicsTwo: WaveformGraphics;

    var port: Port;

    var colOne: Int;
    var colTwo: Int;

    var handle: Handle;
    var targetSwitch: TargetSwitch;

    var sliderOne: VolumeSlider;
    var soundOne: CustomSound;
    var sliderTwo: VolumeSlider;
    var soundTwo: CustomSound;

    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    public function new(p: Object) {
        super(p);

        fromJson(hxd.Res.data.Target.entry);

        // ugly place to put this, target init
        {
        var targetOne = new Sine(4/8, 6/8, 1/8);
        
        // redo this as something more intuitive
        var targetTwo = new WaveformCombination(false);
        targetTwo.weight = 3/6;
        targetTwo.sourceOne = new Sine(1.0, 7/8, 1.0);
        targetTwo.sourceTwo = targetOne;

        // saw wave
        var targetThree = new WaveformCombination(true);
        targetThree.sourceOne = new Triangle(0.5, 0.5, 6/8);
        targetThree.sourceTwo = new Square(0.5, 0.5, 0.5);
        
        // ^U^
        var and = new WaveformCombination(true);
        and.sourceOne = new Triangle(0.5, 3/8, 0.5);
        and.sourceTwo = and.sourceOne;
        var targetFour = new WaveformInverter();
        targetFour.source = and;

        // ideas
        // amplifier

        // replace
        var targetFive = new WaveformCombination(false);
        targetFive.weight = 4/8;
        targetFive.sourceOne = new Sine(0.5, 2/8, 2/8);
        var or = new WaveformCombination(false);
        or.weight = 4/8;
        or.sourceOne = new Triangle(0.5, 1/8, 2/8);
        or.sourceTwo = new Square(4/8, 0.5, 2/8);
        targetFive.sourceTwo = or;

        // this is fine
        var targetSix = new WaveformCombination(true);
        targetSix.sourceOne = new Square(1/8, 0.5, 0.5);
        var invert = new WaveformInverter();
        invert.source = targetSix.sourceOne;
        targetSix.sourceTwo = invert;

        targets = [targetOne, targetTwo, targetThree, targetFour, targetFive, targetSix];
        }
        
        //
        var cols = RNGManager.randoms(colors.length, 2, true);
        colOne = colors[cols[0]];
        colTwo = colors[cols[1]];

        sprite = new Bitmap(Res.img.OscilloOut.toTile().center(), this);
        
        lightOne = new Bitmap(Res.img.Light.toTile().center(), this);
        lightTwo = new Bitmap(Res.img.Light.toTile().center(), this);
        lightThree = new Bitmap(Res.img.Light.toTile().center(), this);
        
        glowOne = new Bitmap(Res.img.LightGlow.toTile().center(), lightOne);
        glowTwo = new Bitmap(Res.img.LightGlow.toTile().center(), lightTwo);
        glowThree = new Bitmap(Res.img.LightGlow.toTile().center(), lightThree);
        for (g in [glowOne, glowTwo, glowThree])
            g.visible = false;

        targetSwitch = new TargetSwitch(checkSolution, this);
        
        targetWaveform = targets[0];
        targetWaveformGraphics = new WaveformGraphics(params.targetWaveformGraphicsWidth, params.targetWaveformGraphicsHeight, colOne, () -> targetWaveform, this);
        inputWaveformGraphics = new WaveformGraphics(params.inputWaveformGraphicsWidth, params.inputWaveformGraphicsHeight, colTwo, () -> inputWaveform, this);
        combinedWaveformGraphicsOne = new WaveformGraphics(params.combinedWaveformGraphicsWidth, params.combinedWaveformGraphicsHeight, colOne, () -> targetWaveform, this);
        combinedWaveformGraphicsTwo = new WaveformGraphics(params.combinedWaveformGraphicsWidth, params.combinedWaveformGraphicsHeight, colTwo, () -> inputWaveform, this);
        
        port = new Port(false, this);
        port.onConnection = (w: Waveform) -> {
            inputWaveform = w;
            soundTwo.waveform = w;
            soundTwo.reload();
            sliderTwo.restore();
        };
        port.onDisconnect = () -> {
            inputWaveform = null;
            soundTwo.reload();
            sliderTwo.mute();
        };
        
        handle = new Handle(this);

        // TODO make this more distinct with an overtone or something
        var sound_channel = SoundManager.addWaveform(targetWaveform);
        soundOne = sound_channel.sound;
        sliderOne = new VolumeSlider(sound_channel.channel, this);

        sound_channel = SoundManager.addWaveform(inputWaveform);
        soundTwo = sound_channel.sound;
        sliderTwo = new VolumeSlider(sound_channel.channel, this);
        sliderTwo.mute();
        
        MessageManager.addListener(this);
        updateGraphics();
    }
    
    function updateGraphics() {
        targetSwitch.startPos.x = params.switchStartX;
        targetSwitch.startPos.y = params.switchStartY;
        targetSwitch.endPos.x = params.switchEndX;
        targetSwitch.endPos.y = params.switchEndY;
        targetSwitch.switchMaxLag = params.switchMaxLag;

        lightOne.x = params.lightOneX;
        lightOne.y = params.lightOneY;
        lightTwo.x = params.lightTwoX;
        lightTwo.y = params.lightTwoY;
        lightThree.x = params.lightThreeX;
        lightThree.y = params.lightThreeY;

        targetWaveformGraphics.x = params.targetWaveformGraphicsX;
        targetWaveformGraphics.y = params.targetWaveformGraphicsY;
        targetWaveformGraphics.width = params.targetWaveformGraphicsWidth;
        targetWaveformGraphics.height = params.targetWaveformGraphicsHeight;
        inputWaveformGraphics.x = params.inputWaveformGraphicsX;
        inputWaveformGraphics.y = params.inputWaveformGraphicsY;
        inputWaveformGraphics.width = params.inputWaveformGraphicsWidth;
        inputWaveformGraphics.height = params.inputWaveformGraphicsHeight;
        combinedWaveformGraphicsOne.x = params.combinedWaveformGraphicsX;
        combinedWaveformGraphicsOne.y = params.combinedWaveformGraphicsY;
        combinedWaveformGraphicsOne.width = params.combinedWaveformGraphicsWidth;
        combinedWaveformGraphicsOne.height = params.combinedWaveformGraphicsHeight;
        combinedWaveformGraphicsTwo.x = params.combinedWaveformGraphicsX;
        combinedWaveformGraphicsTwo.y = params.combinedWaveformGraphicsY;
        combinedWaveformGraphicsTwo.width = params.combinedWaveformGraphicsWidth;
        combinedWaveformGraphicsTwo.height = params.combinedWaveformGraphicsHeight;

        port.x = params.portX;
        port.y = params.portY;
        
        handle.x = params.handleX;
        handle.y = params.handleY;

        sliderOne.x = params.sliderOneX;
        sliderOne.y = params.sliderOneY;
        sliderTwo.x = params.sliderTwoX;
        sliderTwo.y = params.sliderTwoY;

        targetSwitch.updateGraphics();
    }

    public function update(dt:Float):Bool {
        dt *= 0.5;
        inputWaveformGraphics.update(dt);
        targetWaveformGraphics.update(dt);
        combinedWaveformGraphicsOne.update(dt);
        combinedWaveformGraphicsTwo.update(dt);

        combinedWaveformGraphicsTwo.totalTime = combinedWaveformGraphicsOne.totalTime;
        combinedWaveformGraphicsTwo.phaseMod = combinedWaveformGraphicsOne.phaseMod;
        combinedWaveformGraphicsTwo.speed = combinedWaveformGraphicsOne.speed;
        return false;
    }

    function nextPuzzle() {
        for (g in [glowOne, glowTwo, glowThree]) {
            g.color.r = 1;
            g.color.g = 1;
            g.color.b = 1;
            g.visible = false;
        }
        targetSwitch.reset();
        if (puzzlesComplete >= targets.length)
            puzzlesComplete = 0;
        targetWaveform = targets[puzzlesComplete];
        soundOne.waveform = targetWaveform;
        soundOne.reload();
    }

    function checkSolution() {
        for (g in [glowOne, glowTwo, glowThree]) {
            g.visible = true;
            g.alpha = 0;
        }
        Main.tweenManager.animateTo(glowOne, {alpha: 1.0}, 1.0).start();
        Main.tweenManager.delay(0.5, () -> {
            Main.tweenManager.animateTo(glowTwo, {alpha: 1.0}, 1.0).start();
        }).start();
        Main.tweenManager.delay(1, () -> {
            Main.tweenManager.animateTo(glowThree, {alpha: 1.0}, 1.0).start();
        }).start();

        var match = inputWaveform == null ? false : inputWaveform.match(targetWaveform);

        if (match) {
            puzzlesComplete++;
            for (g in [glowOne, glowTwo, glowThree]) {
                g.color.b = 0;
                g.color.r = 0;
            }
            Main.tweenManager.delay(3.0, () -> {MessageManager.send(new Victory());}).start();
            Main.tweenManager.delay(5.0, nextPuzzle).start();
        } else {
            for (g in [glowOne, glowTwo, glowThree]) {
                g.color.g = 0;
                g.color.b = 0;
                Main.tweenManager.delay(3.0, () -> {
                    for (g in [glowOne, glowTwo, glowThree]) {
                        g.color.r = 1;
                        g.color.g = 1;
                        g.color.b = 1;
                        g.visible = false;
                    }
                    targetSwitch.reset();
                }).start();
            }
        }
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UpdateTarget)) {
            var params = cast(msg, UpdateTarget);
            fromJson(params.json);
            updateGraphics();
        }
        return false;
    }
}