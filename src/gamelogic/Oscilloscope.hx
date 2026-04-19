package gamelogic;

import utilities.Utilities.colors;
import h2d.filter.Group;
import h2d.filter.Glow;
import gamelogic.Waveform.waveformMultInverse;
import h2d.filter.Blur;
import utilities.RNGManager;
import utilities.MessageManager;
import utilities.MessageManager.MouseMove;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import hxd.Event;
import h2d.Interactive;
import h2d.Graphics;
import h2d.Object;
import h2d.Bitmap;
import hxd.Res;

class Oscilloscope extends Object implements Updateable
                                  implements MessageListener {
    
    public var waveform: Waveform;
    var waveformGraphics: Graphics;

    var sprite: Bitmap;
    var ampDial: Dial;
    var freqDial: Dial;
    var phaseDial: Dial;

    var totalTime = 0.0;

    var port: Port;

    var isSelected = false;
    var col: Int;
    
    public function new(w: Waveform, p: Object) {
        super(p);
        sprite = new Bitmap(Res.img.Oscillo.toTile().center(), this);
        ampDial = new Dial(() -> {waveform.backup(); waveform.amplitude = ampDial.value/8;}, sprite);
        var size = sprite.getSize();
        ampDial.x = -size.width/4 - 17; // 0.0664*width
        ampDial.y = size.height/4 + 20; // 0.0781*height
        freqDial = new Dial(() -> {waveform.backup(); waveform.frequency = freqDial.value/8;}, sprite);
        freqDial.y = size.height/4 + 20;
        phaseDial = new Dial(() -> {waveform.backup(); waveform.phase = phaseDial.value/8;}, sprite);
        phaseDial.x = size.width/4 + 17;
        phaseDial.y = size.height/4 + 20;

        col = colors[RNGManager.random(colors.length)];

        waveform = w;
        waveformGraphics = new Graphics(this);
        waveformGraphics.scaleX = 212 * waveformMultInverse; 
        waveformGraphics.scaleY = 114 * waveformMultInverse;
        waveformGraphics.x = 20 - size.width/2;
        waveformGraphics.y = 90 - size.height/2;
        waveformGraphics.filter = new Group([new Glow(col, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        port = new Port(true, this);
        port.getOutput = () -> {return waveform;};
        port.x = size.width/2;
        port.y = -size.height/2 + 45;

        var i = new Interactive(141, 16, this);
        i.y = -size.height/2 + 5;
        i.x = -70;
        i.onPush = (e:Event) -> {isSelected = true;}
        i.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        totalTime += dt*0.5 + RNGManager.srand(0.01);
        waveformGraphics.clear();
        waveform.draw(waveformGraphics, totalTime, col);

        ampDial.update(dt);
        freqDial.update(dt);
        phaseDial.update(dt);
        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            x = params.scenePosition.x;
            var size = sprite.getSize();
            y = params.scenePosition.y + size.height/2 - 12;
        }
        return false;
    }
    
}