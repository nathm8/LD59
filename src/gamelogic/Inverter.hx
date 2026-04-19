package gamelogic;

import utilities.RNGManager;
import utilities.Utilities.colors;
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

class Inverter extends Object implements MessageListener
                              implements Updateable {

    var sprite: Bitmap;
    var inputPort: Port;
    var outputPort: Port;

    var isSelected = false;
    var totalTime = 0.0;

    var transformedWaveform: WaveformInverter;

    var inputWaveform: Waveform;
    
    var outputWaveformGraphics: Graphics;
    var outputCol: Int;

    public function new(?p: Object) {
        super(p);

        sprite = new Bitmap(Res.img.Invert.toTile().center(), this);
        var size = sprite.getSize();

        outputCol = colors[RNGManager.random(colors.length)];

        transformedWaveform = new WaveformInverter();
        transformedWaveform.source = inputWaveform;

        outputWaveformGraphics = new Graphics(this);
        outputWaveformGraphics.scaleX = 212 * waveformMultInverse; 
        outputWaveformGraphics.scaleY = 114 * waveformMultInverse; 
        outputWaveformGraphics.x = 22 - size.width/2;
        outputWaveformGraphics.y = 0;
        outputWaveformGraphics.filter = new Group([new Glow(outputCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> {inputWaveform = w; transformedWaveform.source = w;};
        inputPort.onDisconnect = () -> {inputWaveform = null; transformedWaveform.source = null;};
        inputPort.x = -size.width/2;
        inputPort.y = size.height/2 - 45;
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> {return transformedWaveform;};
        outputPort.x = size.width/2;
        outputPort.y = size.height/2 - 45;

        var i = new Interactive(141, 16, this);
        i.y = size.height/2 - 20;
        i.x = -70;
        i.onPush = (e:Event) -> {isSelected = true;}
        i.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        totalTime += dt*0.5;
        outputWaveformGraphics.clear();
        transformedWaveform?.draw(outputWaveformGraphics, totalTime, outputCol);
        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            x = params.scenePosition.x;
            var size = sprite.getSize();
            y = params.scenePosition.y - size.height/2 + 6;
        }
		return false;
	}
}