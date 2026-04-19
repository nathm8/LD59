package gamelogic;

import h2d.filter.Bloom;
import h2d.filter.Group;
import h2d.filter.Glow;
import gamelogic.Waveform.waveformMultInverse;
import h2d.filter.Blur;
import utilities.RNGManager;
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

class Dial extends Object implements MessageListener implements Updateable {
    // between 1 and 8
    public var value = 8;

    var sprite: Bitmap;
    var interactive: Interactive;
    var isSelected = false;
    var moveImmune = 0.25;
    var callback: () -> Void;

    public function new(f: () -> Void, p: Object) {
        super(p);
        callback = f;
        var t = Res.img.Dial.toTile();
        t.setCenterRatio(0.5, 0.83);
        sprite = new Bitmap(t, this);

        interactive = new Interactive(t.width, t.height, this, new Circle(0, 0, 40));
        interactive.enableRightButton = true;
        interactive.onRelease = (e:Event) -> {
            isSelected = false;
        }
        interactive.onPush = (e:Event) -> {
            isSelected = true;
            moveImmune = 0.25;
        }
        interactive.onClick = (e:Event) -> {
            if (e.button == 0)
                value++;
            else
                value--;
            value = value == 0 ? 8 : value == 9 ? 1 : value;
            rotation = value*2*Math.PI/8;
            callback();
        };

        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            if (moveImmune > 0) return false;
            var params = cast(msg, MouseMove);
            var v = new Vector2D(x, y);
            var p = sprite.getAbsPos().getPosition();
            var u = new Vector2D(p.x, p.y);
            var r = normaliseRadian((params.scenePosition - u).angle() + 1.5*Math.PI/8);
            value = Math.round(r/(Math.PI/4)) + 1;
            value = value == 9 ? 1 : value;
            rotation = value*2*Math.PI/8;
            callback();
        }
        return false;
    }

    public function update(dt:Float):Bool {
        if (moveImmune > 0 && isSelected) moveImmune -= dt;
        return false;
    }
}

class Oscilloscope extends Object implements Updateable
                                  implements Connectable
                                  implements MessageListener {
    
    public var waveform: Waveform;
    var waveformGraphics: Graphics;

    var sprite: Bitmap;
    var ampDial: Dial;
    var freqDial: Dial;
    var phaseDial: Dial;

    var totalTime = 0.0;

    var port: Bitmap;
    var portConnected = false;

    var isSelected = false;
    
    public var isOutput: Bool = true;
    public function newInput(c:Connectable) {portConnected = true;}
    public function getWaveform() {return waveform;}
    public function disconnect(c:Connectable) {portConnected = false;}

    public function new(p: Object) {
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

        waveform = new Sine(1, 1, 1);
        waveformGraphics = new Graphics(this);
        waveformGraphics.scaleX = 212 * waveformMultInverse; 
        waveformGraphics.scaleY = 114 * waveformMultInverse;
        waveformGraphics.x = 20 - size.width/2;
        waveformGraphics.y = 90 - size.height/2;
        waveformGraphics.filter = new Group([new Glow(0x00FF00, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        port = new Bitmap(Res.img.CablePort.toTile().center(), this);
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
        waveform.draw(waveformGraphics, totalTime, 0x00FF00);

        ampDial.update(dt);
        freqDial.update(dt);
        phaseDial.update(dt);
        return false;
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
                cable_head.snapTo(new Vector2D(port.x, port.y), this, this);
            }
        }
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