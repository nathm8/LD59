package gamelogic;

import utilities.Vector2D;
import h2d.col.Circle;
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

class TargetOscilloscope extends Object implements Updateable
                                        implements Connectable
                                        implements MessageListener {
    
    var sprite: Bitmap;
    
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
    var combinedWaveform: Waveform;
    var combinedWaveformGraphics: Graphics;

    var port: Bitmap;

    var isSelected = false;
    var portConnected = false;

    var inputTotalTime = 0.0;
    var targetTotalTime = 0.0;
    var combinedTotalTime = 0.0;

    public var isOutput: Bool = false;
    public function newInput(c: Connectable) {
        inputWaveform = c.getWaveform();
        portConnected = true;
    }
    public function getWaveform() {return null;}
    public function disconnect(c: Connectable) {
        inputWaveform = null;
        portConnected = false;
    };

    public function new(p: Object) {
        super(p);
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
        targetWaveformGraphics.scaleX = 310; 
        targetWaveformGraphics.scaleY = 150; 
        targetWaveformGraphics.x = 24 - size.width/2;
        targetWaveformGraphics.y = 96 - size.height/2;

        // inputWaveform = new Sine();
        inputWaveformGraphics = new Graphics(this);
        inputWaveformGraphics.scaleX = 310; 
        inputWaveformGraphics.scaleY = 150; 
        inputWaveformGraphics.x = 24 - size.width/2;
        inputWaveformGraphics.y = 55;

        combinedWaveform = new Sine();
        combinedWaveformGraphics = new Graphics(this);
        combinedWaveformGraphics.scaleX = 310; 
        combinedWaveformGraphics.scaleY = 320; 
        combinedWaveformGraphics.x = 12;
        combinedWaveformGraphics.y = -34;

        port = new Bitmap(Res.img.CablePort.toTile().center(), this);
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
        targetWaveform.draw(targetWaveformGraphics, targetTotalTime);
        inputWaveform?.draw(inputWaveformGraphics, inputTotalTime);
        targetWaveform.draw(combinedWaveformGraphics, combinedTotalTime);
        inputWaveform?.draw(combinedWaveformGraphics, combinedTotalTime);
        return false;
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
            for (g in [glowOne, glowTwo, glowThree]) {
                g.color.b = 0;
                g.color.r = 0;
            }
            Main.tweenManager.delay(3.0, () -> {MessageManager.send(new Victory());}).start();
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
        if (Std.isOfType(msg, CableHeadMoved)) {
            var params = cast(msg, CableHeadMoved);
            if (portConnected) return false;
            var cable_head = params.cableHead;
            var cable_bounds = cable_head.interactive.getBounds();
            var p: Vector2D = port.getAbsPos().getPosition();
            var c = new Circle(p.x, p.y, 30);
            if (cable_bounds.collideCircle(c)) {
                cable_head.snapTo(p, this, () -> {pos: new Vector2D(port.x, port.y), object: this});
            }
        }
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