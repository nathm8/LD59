package gamelogic;

import gamelogic.Waveform.WaveformCombination;
import gamelogic.Waveform.Square;
import h2d.filter.Blur;
import h2d.filter.Glow;
import h2d.filter.Group;
import gamelogic.Waveform.waveformMultInverse;
import utilities.RNGManager;
import utilities.MessageManager;
import hxd.Event;
import h2d.col.PixelsCollider;
import h2d.Interactive;
import h2d.Graphics;
import gamelogic.Waveform.Sine;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

var targets = new Array<Waveform>();

class TargetOscilloscope extends Object implements Updateable
                                        implements MessageListener {
    
    var sprite: Bitmap;
    
    var puzzlesComplete = 0;

    var switchReady: Bitmap;
    var switchFlipped: Bitmap;
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

    var isSelected = false;

    var inputTotalTime = 0.0;
    var targetTotalTime = 0.0;
    var combinedTotalTime = 0.0;

    public function new(p: Object) {
        super(p);

        // ugly place to put this, but target init
        var targetOne = new Sine(4/8, 6/8, 1/8);
        var targetTwo = new WaveformCombination(false);
        targetTwo.weight = 6/9;
        targetTwo.sourceOne = targetOne;
        targetTwo.sourceTwo = new Square(5/8, 4/8, 2/8);
        // var targetThree = new WaveformCombination(true);
        targets = [targetOne, targetTwo];
        //


        sprite = new Bitmap(Res.img.OscilloOut.toTile().center(), this);
        var size = sprite.getSize();
        var t = Res.img.SwitchReady.toTile();
        t.setCenterRatio(0.5, 0.5);
        switchReady = new Bitmap(t, sprite);
        switchReady.x = -size.width/4 + 1;
        switchReady.y = size.height/4 + 67;

        var pixels = new PixelsCollider(t.getTexture().capturePixels());
        var i = new Interactive(t.width, t.height, switchReady, pixels);
        i.x -= t.width/2;
        i.y -= t.height/2;
        i.onPush = (e: Event) -> {checkSolution();};

        t = Res.img.SwitchFlipped.toTile();
        t.setCenterRatio(0.5, 0.5);
        switchFlipped = new Bitmap(t, sprite);
        switchFlipped.x = -size.width/4 + 4;
        switchFlipped.y = size.height/4 + 67;
        switchFlipped.visible = false;

        t = Res.img.Light.toTile().center();
        lightOne = new Bitmap(t, sprite);
        lightOne.x = 57;
        lightOne.y = size.height/4 + 66;
        lightTwo = new Bitmap(t, sprite);
        lightTwo.x = lightOne.x + 109;
        lightTwo.y = lightOne.y;
        lightThree = new Bitmap(t, sprite);
        lightThree.x = lightTwo.x + 109;
        lightThree.y = lightOne.y;

        t = Res.img.LightGlow.toTile().center();
        glowOne = new Bitmap(t, lightOne);
        glowTwo = new Bitmap(t, lightTwo);
        glowThree = new Bitmap(t, lightThree);
        for (g in [glowOne, glowTwo, glowThree])
            g.visible = false;

        targetWaveform = new Sine();
        targetWaveformGraphics = new Graphics(this);
        targetWaveformGraphics.scaleX = 310 * waveformMultInverse; 
        targetWaveformGraphics.scaleY = 150 * waveformMultInverse; 
        targetWaveformGraphics.x = 24 - size.width/2;
        targetWaveformGraphics.y = 96 - size.height/2;
        targetWaveformGraphics.filter = new Group([new Glow(0x0000FF, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        // inputWaveform = new Sine();
        inputWaveformGraphics = new Graphics(this);
        inputWaveformGraphics.scaleX = 310 * waveformMultInverse; 
        inputWaveformGraphics.scaleY = 150 * waveformMultInverse; 
        inputWaveformGraphics.x = 24 - size.width/2;
        inputWaveformGraphics.y = 55;
        inputWaveformGraphics.filter = new Group([new Glow(0x00FF00, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        combinedWaveformGraphics = new Graphics(this);
        combinedWaveformGraphics.scaleX = 310 * waveformMultInverse; 
        combinedWaveformGraphics.scaleY = 320 * waveformMultInverse; 
        combinedWaveformGraphics.x = 12;
        combinedWaveformGraphics.y = -34;
        combinedWaveformGraphics.filter = new Group([new Glow(0xFFFFFF, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        port = new Port(false, this);
        port.onConnection = (w: Waveform) -> {inputWaveform = w;};
        port.onDisconnect = () -> {inputWaveform = null;};
        port.x = -size.width/2;
        port.y = size.height/2 - 110;

        // 141, 11
        var i = new Interactive(141, 16, this);
        i.y = -size.height/2 + 3;
        i.x = -70;
        i.onPush = (e:Event) -> {isSelected = true;}
        i.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        targetTotalTime += dt*0.5 + RNGManager.srand(0.01);
        inputTotalTime += dt*0.5 + RNGManager.srand(0.01);
        combinedTotalTime += dt*0.5 + RNGManager.srand(0.01);
        targetWaveformGraphics.clear();
        inputWaveformGraphics.clear();
        combinedWaveformGraphics.clear();
        targetWaveform.draw(targetWaveformGraphics, targetTotalTime, 0x0000DD);
        inputWaveform?.draw(inputWaveformGraphics, inputTotalTime);
        targetWaveform.draw(combinedWaveformGraphics, combinedTotalTime, 0x0000DD);
        inputWaveform?.draw(combinedWaveformGraphics, combinedTotalTime);
        return false;
    }

    function nextPuzzle() {
        for (g in [glowOne, glowTwo, glowThree]) {
            g.color.r = 1;
            g.color.g = 1;
            g.color.b = 1;
            g.visible = false;
        }
        switchReady.visible = true;
        switchFlipped.visible = false;
        if (puzzlesComplete >= targets.length) {
            // todo: generate random waveform
            targetWaveform = targets[1];
        } else {
            targetWaveform = targets[puzzlesComplete];
        }
    }

    function checkSolution() {
        switchReady.visible = false;
        switchFlipped.visible = true;
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
                    switchReady.visible = true;
                    switchFlipped.visible = false;
                }).start();
            }
        }
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            x = params.scenePosition.x;
            var size = sprite.getSize();
            y = params.scenePosition.y + size.height/2 - 8;
        }
        return false;
    }
}