package gamelogic;

import utilities.MessageManager;
import hxd.Event;
import h2d.Interactive;
import h2d.filter.Blur;
import h2d.filter.Glow;
import h2d.filter.Group;
import gamelogic.Waveform.waveformMultInverse;
import hxd.Res;
import h2d.Graphics;
import h2d.Bitmap;
import utilities.MessageManager.MessageListener;
import h2d.Object;
import gamelogic.Waveform.WaveformInverter;

class Splitter extends Object implements MessageListener
                              implements Updateable {

    var sprite: Bitmap;
    var inputPort: Port;
    var outputPortOne: Port;
    var outputPortTwo: Port;

    var waveform: Waveform;

    var isSelected = false;

    public function new(?p: Object) {
        super(p);

        sprite = new Bitmap(Res.img.Split.toTile().center(), this);
        var size = sprite.getSize();

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> {waveform = w;};
        inputPort.onDisconnect = () -> {waveform = null;};
        inputPort.x = -size.width/2;
        inputPort.y = 20;
        
        outputPortOne = new Port(true, this);
        outputPortOne.getOutput = () -> {return waveform;};
        outputPortOne.x = size.width/2;
        outputPortOne.y = -20;

        outputPortTwo = new Port(true, this);
        outputPortTwo.getOutput = () -> {return waveform;};
        outputPortTwo.x = size.width/2;
        outputPortTwo.y = 20;

        var i = new Interactive(141, 16, this);
        i.y = -size.height/2 + 5;
        i.x = -70;
        i.onPush = (e:Event) -> {isSelected = true;}
        i.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
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