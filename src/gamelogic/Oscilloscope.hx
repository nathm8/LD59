package gamelogic;

import h2d.filter.Mask;
import gamelogic.Waveform.Sine;
import h2d.Graphics;
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
        return false;
    }
}

class Oscilloscope extends Object implements Updateable {
    
    var waveform: Waveform;
    var waveformGraphics: Graphics;

    var sprite: Bitmap;
    var ampDial: Dial;
    var freqDial: Dial;
    var phaseDial: Dial;

    var totalTime = 0.0;

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

        waveform = new Sine();
        waveformGraphics = new Graphics(this);
        waveformGraphics.scaleX = 212; 
        waveformGraphics.scaleY = 114; 
        waveformGraphics.x = 20 - size.width/2;
        waveformGraphics.y = 20 - waveformGraphics.scaleY/2;
    }

    public function update(dt:Float):Bool {
        totalTime += dt;
        waveformGraphics.clear();
        waveform.draw(waveformGraphics, totalTime);
        // ampDial.update(dt);
        // freqDial.update(dt);
        // phaseDial.update(dt);
        return false;
    }
}