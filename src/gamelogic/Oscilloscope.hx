package gamelogic;

import h2d.Object;
import h2d.Bitmap;
import hxd.Res;

class Dial extends Object implements Updateable {

    var sprite: Bitmap;

    public function new(p: Object) {
        super(p);
        var t = Res.img.Dial.toTile();
        t.setCenterRatio(0.5, 0.83);
        sprite = new Bitmap(t, this);
    }

    public function update(dt:Float):Bool {
        sprite.rotation += dt;
        return false;
    }
}

class Oscilloscope extends Object implements Updateable {
    
    var sprite: Bitmap;
    var ampDial: Dial;
    var freqDial: Dial;
    var phaseDial: Dial;

    public function new(p: Object) {
        super(p);
        sprite = new Bitmap(Res.img.Oscillo.toTile().center(), this);
        ampDial = new Dial(sprite);
        var size = sprite.getSize();
        ampDial.x = -size.width/4 - 17; // 0.0664*width
        ampDial.y = size.height/4 + 20; // 0.0781*height
        freqDial = new Dial(sprite);
        freqDial.y = size.height/4 + 20;
        phaseDial = new Dial(sprite);
        phaseDial.x = size.width/4 + 17;
        phaseDial.y = size.height/4 + 20;
    }

    public function update(dt:Float):Bool {
        ampDial.update(dt);
        freqDial.update(dt);
        phaseDial.update(dt);
        return false;
    }
}