package gamelogic;

import gamelogic.Waveform.waveformMult;
import utilities.Utilities.colors;
import gamelogic.Waveform.WaveformCombination;
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
    var totalTimeThree = 0.0;

    var transformedWaveform: WaveformCombination;

    var inputWaveformOne: Waveform;
    var inputWaveformGraphicsOne: Graphics;
    var inputOneCol = 0xFF00FF;
    var inputWaveformTwo: Waveform;
    var inputWaveformGraphicsTwo: Graphics;
    var inputTwoCol = 0x00FFFF;

    var outputWaveformGraphics: Graphics;
    var outputCol = 0x00FFFF;

    public function new(a: Bool, ?p: Object) {
        super(p);
        isAnd = a;

        if (isAnd)
            sprite = new Bitmap(Res.img.And.toTile().center(), this);
        else
            sprite = new Bitmap(Res.img.Or.toTile().center(), this);
        var size = sprite.getSize();

        dial = new Dial(() -> {transformedWaveform.weight = dial.value/9;}, this);
        if (isAnd) {
            dial.x = 3 - size.width/4;
            dial.y = 6;
        } else {
            dial.y = -63;
        }

        inputOneCol = colors[RNGManager.random(colors.length)];
        inputTwoCol = colors[RNGManager.random(colors.length)];
        outputCol = colors[RNGManager.random(colors.length)];

        inputWaveformOne = new Sine(1, 1/8, 1);
        inputWaveformTwo = new Sine(1, 1/8, 1);

        transformedWaveform = new WaveformCombination(isAnd);
        transformedWaveform.sourceOne = inputWaveformOne;
        transformedWaveform.sourceTwo = inputWaveformTwo;
        transformedWaveform.weight = 1;

        outputWaveformGraphics = new Graphics(this);
        outputWaveformGraphics.scaleX = 212 * waveformMultInverse;
        outputWaveformGraphics.scaleY = 114 * waveformMultInverse;
        if (isAnd) {
            outputWaveformGraphics.x = size.width/4 - 106;
            outputWaveformGraphics.y = 5;
        } else {
            outputWaveformGraphics.x = -106;
            outputWaveformGraphics.y = size.height/4;
        }

        inputWaveformGraphicsOne = new Graphics(this);
        inputWaveformGraphicsOne.scaleX = 212 * waveformMultInverse;
        inputWaveformGraphicsOne.scaleY = 114 * waveformMultInverse;
        if (isAnd) {
            inputWaveformGraphicsOne.x = 24 - size.width/2;
            inputWaveformGraphicsOne.y = -115;
        } else {
            inputWaveformGraphicsOne.x = 20 - size.width/2;
            inputWaveformGraphicsOne.y = -66;
        }
        inputWaveformGraphicsOne.filter = new Group([new Glow(inputOneCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputWaveformGraphicsTwo = new Graphics(this);
        inputWaveformGraphicsTwo.scaleX = 212 * waveformMultInverse; 
        inputWaveformGraphicsTwo.scaleY = 114 * waveformMultInverse; 
        if (isAnd) {
            inputWaveformGraphicsTwo.x = 24 - size.width/2;
            inputWaveformGraphicsTwo.y = 120;
        } else {
            inputWaveformGraphicsTwo.x = 60;
            inputWaveformGraphicsTwo.y = -66;
        }
        inputWaveformGraphicsTwo.filter = new Group([new Glow(inputTwoCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputPortOne = new Port(false, this);
        inputPortOne.onConnection = (w) -> {inputWaveformOne = w; transformedWaveform.sourceOne = w;};
        inputPortOne.onDisconnect = () -> {inputWaveformOne = null; transformedWaveform.sourceOne = null;};
        inputPortOne.x = -size.width/2;
        if (isAnd)
            inputPortOne.y = -size.height/2 + 50;
        else
            inputPortOne.y = -size.height/2 + 50;

        inputPortTwo = new Port(false, this);
        inputPortTwo.onConnection = (w) -> {inputWaveformTwo = w; transformedWaveform.sourceTwo = w;};
        inputPortTwo.onDisconnect = () -> {inputWaveformTwo = null; transformedWaveform.sourceTwo = null;};
        inputPortTwo.x = -size.width/2;
        if (isAnd)
            inputPortTwo.y = size.height/2 - 45;
        else
            inputPortTwo.y = -size.height/2 + 130;
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> {return transformedWaveform;};
        outputPort.x = size.width/2;
        if (isAnd)
            outputPort.y = 10;
        else
            outputPort.y = -size.height/2 + 130;

        var i = new Interactive(141, 16, this);
        
        if (isAnd) {
            i.y = 5 - size.height/2;
            i.x = 58 - size.width/2;
        } else {
            i.y = 5 - size.height/2;
            i.x = -70;
        }
        i.onPush = (e:Event) -> {isSelected = true;}
        i.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        totalTimeOne += dt*0.5 + RNGManager.srand(0.01);
        inputWaveformGraphicsOne.clear();
        // inputWaveformGraphicsOne.scaleY = transformedWaveform.weight * 114 * waveformMultInverse;
        inputWaveformOne?.draw(inputWaveformGraphicsOne, totalTimeOne, inputOneCol);
        totalTimeTwo += dt*0.5 + RNGManager.srand(0.01);
        inputWaveformGraphicsTwo.clear();
        // if (isAnd)
        //     inputWaveformGraphicsTwo.scaleY = transformedWaveform.weight * 114 * waveformMultInverse;
        // else
        //     inputWaveformGraphicsTwo.scaleY = (1 - transformedWaveform.weight) * 114 * waveformMultInverse;
        inputWaveformTwo?.draw(inputWaveformGraphicsTwo, totalTimeTwo, inputTwoCol);
        
        totalTimeThree += dt*0.5 + RNGManager.srand(0.01);
        outputWaveformGraphics.clear();
        transformedWaveform?.draw(outputWaveformGraphics, totalTimeThree, outputCol);

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
            if (isAnd) {
                x += 100;
            } else {
            }
        }
		return false;
	}
}