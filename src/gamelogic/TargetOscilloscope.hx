package gamelogic;

import h2d.Graphics;
import gamelogic.Waveform.Sine;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

class TargetOscilloscope extends Object implements Updateable {
    
    var sprite: Bitmap;
    
    var switchReady: Bitmap;
    var switchFlipped: Bitmap;
    var lightOne: Bitmap;
    var lightTwo: Bitmap;
    var lightThree: Bitmap;
    var glowOne: Bitmap;
    var glowTwo: Bitmap;
    var glowThree: Bitmap;

    var inputWaveform: Waveform;
    var inputWaveformGraphics: Graphics;
    var targetWaveform: Waveform;
    var targetWaveformGraphics: Graphics;
    var combinedWaveform: Waveform;
    var combinedWaveformGraphics: Graphics;

    var totalTime = 0.0;

    public function new(p: Object) {
        super(p);
        sprite = new Bitmap(Res.img.OscilloOut.toTile().center(), this);
        var size = sprite.getSize();
        var t = Res.img.SwitchReady.toTile();
        t.setCenterRatio(0.5, 0.5);
        switchReady = new Bitmap(t, sprite);
        switchReady.x = -size.width/4 + 1;
        switchReady.y = size.height/4 + 67;
        t = Res.img.SwitchFlipped.toTile();
        t.setCenterRatio(0.5, 0.5);
        switchFlipped = new Bitmap(t, sprite);
        switchFlipped.x = -size.width/4 + 4;
        switchFlipped.y = size.height/4 + 67;

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

        targetWaveform = new Sine();
        targetWaveformGraphics = new Graphics(this);
        targetWaveformGraphics.beginFill(0xFF0000);
        targetWaveformGraphics.drawRect(0, -0.5, 1, 1);
        targetWaveformGraphics.endFill();
        targetWaveformGraphics.scaleX = 310; 
        targetWaveformGraphics.scaleY = 150; 
        targetWaveformGraphics.x = 24 - size.width/2;
        targetWaveformGraphics.y = 96 - size.height/2;

        inputWaveform = new Sine();
        inputWaveformGraphics = new Graphics(this);
        inputWaveformGraphics.beginFill(0xFF0000);
        inputWaveformGraphics.drawRect(0, -0.5, 1, 1);
        inputWaveformGraphics.endFill();
        inputWaveformGraphics.scaleX = 310; 
        inputWaveformGraphics.scaleY = 150; 
        inputWaveformGraphics.x = 24 - size.width/2;
        inputWaveformGraphics.y = 55;

        combinedWaveform = new Sine();
        combinedWaveformGraphics = new Graphics(this);
        combinedWaveformGraphics.beginFill(0xFF0000);
        combinedWaveformGraphics.drawRect(0, -0.5, 1, 1);
        combinedWaveformGraphics.endFill();
        combinedWaveformGraphics.scaleX = 310; 
        combinedWaveformGraphics.scaleY = 320; 
        combinedWaveformGraphics.x = 12;
        combinedWaveformGraphics.y = -34;

    }

    public function update(dt:Float):Bool {
        totalTime += dt;
        targetWaveformGraphics.clear();
        inputWaveformGraphics.clear();
        combinedWaveformGraphics.clear();
        targetWaveform.draw(targetWaveformGraphics, totalTime);
        inputWaveform.draw(inputWaveformGraphics, totalTime);
        targetWaveform.draw(combinedWaveformGraphics, totalTime);
        inputWaveform.draw(combinedWaveformGraphics, totalTime);
        return false;
    }
}