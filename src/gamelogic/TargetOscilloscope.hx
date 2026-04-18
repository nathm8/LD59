package gamelogic;

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
    }

    public function update(dt:Float):Bool {
        return false;
    }
}