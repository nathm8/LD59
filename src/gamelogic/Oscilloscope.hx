package gamelogic;

import h2d.col.Circle;
import utilities.MessageManager;
import utilities.MessageManager.MouseMove;
import utilities.Utilities.normaliseRadian;
import h2d.col.Point;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import utilities.Vector2D;
import hxd.Event;
import h2d.col.PixelsCollider;
import h2d.Interactive;
import h2d.filter.Mask;
import gamelogic.Waveform.Sine;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import hxd.Res;

class Dial extends Object {
    // between 1 and 8
    public var value = 8;

    var sprite: Bitmap;
    var interactive: Interactive;
    var callback: () -> Void;

    public function new(f: () -> Void, p: Object) {
        super(p);
        callback = f;
        var t = Res.img.Dial.toTile();
        t.setCenterRatio(0.5, 0.83);
        sprite = new Bitmap(t, this);

        interactive = new Interactive(t.width, t.height, this, new Circle(0, 0, 40));
        interactive.enableRightButton = true;
        interactive.onPush = (e:Event) -> {
            if (e.button == 0)
                value++;
            else
                value--;
            value = value == 0 ? 8 : value == 9 ? 1 : value;
            rotation = value*2*Math.PI/8;
            callback();
        };
    }
}

class Oscilloscope extends Object implements Updateable {
    
    public var waveform: Waveform;
    var waveformGraphics: Graphics;

    var sprite: Bitmap;
    var ampDial: Dial;
    var freqDial: Dial;
    var phaseDial: Dial;

    var totalTime = 0.0;

    public function new(p: Object) {
        super(p);
        sprite = new Bitmap(Res.img.Oscillo.toTile().center(), this);
        ampDial = new Dial(() -> {waveform.amplitude = ampDial.value/8;}, sprite);
        var size = sprite.getSize();
        ampDial.x = -size.width/4 - 17; // 0.0664*width
        ampDial.y = size.height/4 + 20; // 0.0781*height
        freqDial = new Dial(() -> {waveform.frequency = freqDial.value/8;}, sprite);
        freqDial.y = size.height/4 + 20;
        phaseDial = new Dial(() -> {waveform.phase = phaseDial.value/8;}, sprite);
        phaseDial.x = size.width/4 + 17;
        phaseDial.y = size.height/4 + 20;

        waveform = new Sine(1, 1, 1);
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