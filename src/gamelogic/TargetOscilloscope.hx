package gamelogic;

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
            // TODO tween this
            setActiveSpritesPositions(1);
            isSelected = false;
        };

        switchFlipped = new Bitmap(Res.img.SwitchOff.toTile().center(), this);
        switchFlipped.visible = false;
        switchFlipped.x = endPos.x;
        switchFlipped.y = endPos.y;

        MessageManager.addListener(this);
    }

    // r in [0, 1] ratio between startPos and endPos, 1 = startPos
    function setActiveSpritesPositions(r: Float) {
        switchReady.x = r*startPos.x + (1-r)*endPos.x;
        switchReady.x = clamp(switchReady.x, startPos.x, endPos.x);

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
        // TODO tween
        switchReady.x = startPos.x;
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
    var inputWaveformGraphicsWidth: Float;
    var inputWaveformGraphicsHeight: Float;
    var inputWaveformGraphicsX: Float;
    var inputWaveformGraphicsY: Float;
    var targetWaveformGraphicsWidth: Float;
    var targetWaveformGraphicsHeight: Float;
    var targetWaveformGraphicsX: Float;
    var targetWaveformGraphicsY: Float;
    var combinedWaveformGraphicsWidth: Float;
    var combinedWaveformGraphicsHeight: Float;
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
    var inputWaveformGraphics: Graphics;
    var targetWaveform: Waveform;
    var targetWaveformGraphics: Graphics;
    var combinedWaveformGraphics: Graphics;

    var port: Port;

    var inputTotalTime = 0.0;
    var targetTotalTime = 0.0;
    var combinedTotalTime = 0.0;

    var colOne: Int;
    var colTwo: Int;
    var colThree: Int;

    var handle: Handle;
    var targetSwitch: TargetSwitch;

    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    public function new(p: Object) {
        super(p);

        // ugly place to put this, target init
        {
        var targetOne = new Sine(4/8, 6/8, 1/8);
        
        var targetTwo = new WaveformCombination(false);
        targetTwo.weight = 6/9;
        targetTwo.sourceOne = targetOne;
        targetTwo.sourceTwo = new Square(1, 1, 1);

        var targetThree = new WaveformCombination(true);
        targetThree.weight = 8/9;
        targetThree.sourceOne = new Triangle(1, 1, 4/8);
        targetThree.sourceTwo = new Square(1, 1, 1);
        
        var and = new WaveformCombination(true);
        and.weight = 4/9;
        and.sourceOne = new Triangle(1, 3/8, 1);
        and.sourceTwo = and.sourceOne;
        var targetFour = new WaveformInverter();
        targetFour.source = and;

        var targetFive = new WaveformCombination(false);
        targetFive.weight = 4/9;
        targetFive.sourceOne = new Sine(1, 2/8, 2/8);
        var or = new WaveformCombination(false);
        or.weight = 4/9;
        or.sourceOne = new Triangle(1, 1/8, 2/8);
        or.sourceTwo = new Square(4/8, 1, 2/8);
        targetFive.sourceTwo = or;

        var targetSix = new WaveformCombination(true);
        targetSix.weight = 1/9;
        targetSix.sourceOne = new Square(1/8, 1 ,1);
        var invert = new WaveformInverter();
        invert.source = targetSix.sourceOne;
        targetSix.sourceTwo = invert;

        targets = [targetOne, targetTwo, targetThree, targetFour, targetFive, targetSix];
        }
        //
        var cols = RNGManager.randoms(colors.length, 3, true);
        colOne = colors[cols[0]];
        colTwo = colors[cols[1]];
        colThree = colors[cols[2]];

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
        targetWaveformGraphics = new Graphics(this);
        targetWaveformGraphics.filter = new Group([new Glow(colOne, 1, 10, 1, 1, true), new Blur(60, 1.1)]);
        
        // inputWaveform = new Sine();
        inputWaveformGraphics = new Graphics(this);
        inputWaveformGraphics.filter = new Group([new Glow(colTwo, 1, 10, 1, 1, true), new Blur(60, 1.1)]);
        
        combinedWaveformGraphics = new Graphics(this);
        combinedWaveformGraphics.filter = new Group([new Glow(colThree, 1, 10, 1, 1, true), new Blur(60, 1.1)]);
        
        port = new Port(false, this);
        port.onConnection = (w: Waveform) -> {inputWaveform = w;};
        port.onDisconnect = () -> {inputWaveform = null;};
        
        handle = new Handle(this);
        
        MessageManager.addListener(this);
        fromJson(hxd.Res.data.Target.entry);
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
        inputWaveformGraphics.x = params.inputWaveformGraphicsX;
        inputWaveformGraphics.y = params.inputWaveformGraphicsY;
        combinedWaveformGraphics.x = params.combinedWaveformGraphicsX;
        combinedWaveformGraphics.y = params.combinedWaveformGraphicsY;

        port.x = params.portX;
        port.y = params.portY;
        
        handle.x = params.handleX;
        handle.y = params.handleY;

        targetSwitch.updateGraphics();
    }

    public function update(dt:Float):Bool {
        targetTotalTime += dt*0.5 + RNGManager.srand(0.01);
        inputTotalTime += dt*0.5 + RNGManager.srand(0.01);
        combinedTotalTime += dt*0.5 + RNGManager.srand(0.01);
        targetWaveformGraphics.clear();
        inputWaveformGraphics.clear();
        combinedWaveformGraphics.clear();
        targetWaveform.draw(targetWaveformGraphics, params.targetWaveformGraphicsWidth, params.targetWaveformGraphicsHeight, targetTotalTime, colOne);
        inputWaveform?.draw(inputWaveformGraphics, params.inputWaveformGraphicsWidth, params.inputWaveformGraphicsHeight, inputTotalTime, colTwo);
        targetWaveform.draw(combinedWaveformGraphics, params.combinedWaveformGraphicsWidth, params.combinedWaveformGraphicsHeight, combinedTotalTime, colOne);
        inputWaveform?.draw(combinedWaveformGraphics, params.combinedWaveformGraphicsWidth, params.combinedWaveformGraphicsHeight, combinedTotalTime, colTwo);
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