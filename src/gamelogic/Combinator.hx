package gamelogic;

import gamelogic.Waveform.Sine;
import utilities.RNGManager;
import hxd.Event;
import h2d.Interactive;
import h2d.filter.Blur;
import h2d.filter.Glow;
import gamelogic.Waveform.waveformMultInverse;
import h2d.filter.Group;
import utilities.MessageManager;
import h2d.Graphics;
import hxd.Res;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import h2d.Object;
import h2d.Bitmap;

class WaveformCombination extends Waveform {

    public var sourceOne: Waveform;
    public var sourceTwo: Waveform;
    // [0, 1]
    public var weight = 4/9;

    var isAnd: Bool;

    public function new(a: Bool) {
        super();
        isAnd = a;
    }

    override public function sample(t:Float):Float {
        if (sourceOne == null || sourceTwo == null) return 0;
        var y: Float;
        if (isAnd)
            y = weight*sourceOne.sample(t) * (1 - weight)*sourceTwo.sample(t);
        else
            y = weight*sourceOne.sample(t) + (1 - weight)*sourceTwo.sample(t);
        y = y > 0.5 ? 0.5 : y < -0.5 ? -0.5 : y;
        return y;
    }

    override public function samplePreviousWeighted(t:Float, w:Float):Float {
        return sample(t);
    }
}

class Combinator extends Object implements MessageListener
                                implements Updateable {
                                    
    var isAnd: Bool; // otherwise Or
    var sprite: Bitmap;
    var dial: Dial;
    var inputPortOne: Port;
    var inputPortTwo: Port;
    var outputPort: Port;

    var isSelected = false;
    var totalTimeOne = 0.0;
    var totalTimeTwo = 0.0;

    var transformedWaveform: WaveformCombination;

    var inputWaveformOne: Waveform;
    var inputWaveformGraphicsOne: Graphics;
    var inputOneCol = 0xFF00FF;
    var inputWaveformTwo: Waveform;
    var inputWaveformGraphicsTwo: Graphics;
    var inputTwoCol = 0x00FFFF;

    public function new(a: Bool, ?p: Object) {
        super(p);
        isAnd = a;

        if (isAnd)
            sprite = new Bitmap(Res.img.And.toTile().center(), this);
        else
            sprite = new Bitmap(Res.img.Or.toTile().center(), this);
        var size = sprite.getSize();

        dial = new Dial(() -> {transformedWaveform.weight = dial.value/9;}, this);
        dial.y = 6;

        inputWaveformOne = new Sine(1,1,1);
        inputWaveformTwo = new Sine(1,1,1);

        transformedWaveform = new WaveformCombination(isAnd);

        inputWaveformGraphicsOne = new Graphics(this);
        inputWaveformGraphicsOne.scaleX = 212 * waveformMultInverse; 
        inputWaveformGraphicsOne.scaleY = 114 * waveformMultInverse; 
        inputWaveformGraphicsOne.x = 24 - size.width/2;
        inputWaveformGraphicsOne.y = -115;
        inputWaveformGraphicsOne.filter = new Group([new Glow(inputOneCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputWaveformGraphicsTwo = new Graphics(this);
        // inputWaveformGraphicsTwo.beginFill(0xFF0000);
        // inputWaveformGraphicsTwo.drawRect(0, 0, 212, 114);
        inputWaveformGraphicsTwo.scaleX = 212 * waveformMultInverse; 
        inputWaveformGraphicsTwo.scaleY = 114 * waveformMultInverse; 
        inputWaveformGraphicsTwo.x = 24 - size.width/2;
        inputWaveformGraphicsTwo.y = 120;
        inputWaveformGraphicsTwo.filter = new Group([new Glow(inputTwoCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputPortOne = new Port(false, this);
        inputPortOne.onConnection = (w) -> {inputWaveformOne = w; transformedWaveform.sourceOne = w;};
        inputPortOne.onDisconnect = () -> {inputWaveformOne = null; transformedWaveform.sourceOne = null;};
        inputPortOne.x = -size.width/2;
        inputPortOne.y = -size.height/2 + 50;

        inputPortTwo = new Port(false, this);
        inputPortTwo.onConnection = (w) -> {inputWaveformTwo = w; transformedWaveform.sourceTwo = w;};
        inputPortTwo.onDisconnect = () -> {inputWaveformTwo = null; transformedWaveform.sourceTwo = null;};
        inputPortTwo.x = -size.width/2;
        inputPortTwo.y = size.height/2 - 45;
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> {return transformedWaveform;};
        outputPort.x = size.width/2;
        outputPort.y = 10;

        var i = new Interactive(141, 16, this);
        i.y = -size.height/2 + 5;
        i.x = -70;
        i.onPush = (e:Event) -> {isSelected = true;}
        i.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        totalTimeOne += dt*0.5 + RNGManager.srand(0.01);
        inputWaveformGraphicsOne.clear();
        inputWaveformGraphicsOne.scaleY = transformedWaveform.weight * 114 * waveformMultInverse;
        inputWaveformOne?.draw(inputWaveformGraphicsOne, totalTimeOne, inputOneCol);
        totalTimeTwo += dt*0.5 + RNGManager.srand(0.01);
        inputWaveformGraphicsTwo.clear();
        inputWaveformGraphicsTwo.scaleY = (1 - transformedWaveform.weight) * 114 * waveformMultInverse;
        inputWaveformTwo?.draw(inputWaveformGraphicsTwo, totalTimeTwo, inputTwoCol);

        dial.update(dt);
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