package gamelogic;

import graphics.Handle;
import haxe.Json;
import hxd.Res;
import hxd.fs.FileEntry;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Object;
import h2d.filter.Blur;
import h2d.filter.Glow;
import h2d.filter.Group;
import utilities.Utilities.colors;
import utilities.RNGManager;
import utilities.MessageManager;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import gamelogic.Waveform.WaveformCombination;
import gamelogic.Waveform.waveformMultInverse;

typedef CombinatorJson = {
    var inputWaveformGraphicsOneWidth: Float;
    var inputWaveformGraphicsOneHeight: Float;
    var inputWaveformGraphicsOneX: Float;
    var inputWaveformGraphicsOneY: Float;
    var inputWaveformGraphicsTwoWidth: Float;
    var inputWaveformGraphicsTwoHeight: Float;
    var inputWaveformGraphicsTwoX: Float;
    var inputWaveformGraphicsTwoY: Float;
    var outputWaveformGraphicsWidth: Float;
    var outputWaveformGraphicsHeight: Float;
    var outputWaveformGraphicsX: Float;
    var outputWaveformGraphicsY: Float;

    var dialX: Float;
    var dialY: Float;

    var inputPortOneX: Float;
    var inputPortOneY: Float;
    var inputPortTwoX: Float;
    var inputPortTwoY: Float;
    var outputPortX: Float;
    var outputPortY: Float;

    var handleX: Float;
    var handleY: Float;
}

class Combinator extends Object implements MessageListener
                                implements Updateable {
                                    
    var isAnd: Bool; // otherwise Or
    var sprite: Bitmap;
    var dial: Dial;
    var inputPortOne: Port;
    var inputPortTwo: Port;
    var outputPort: Port;
    var handle: Handle;

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

    var params: CombinatorJson;

    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    function updateGraphics() {
        outputWaveformGraphics.scaleX = params.outputWaveformGraphicsWidth * waveformMultInverse;
        outputWaveformGraphics.scaleY = params.outputWaveformGraphicsHeight * waveformMultInverse;
        outputWaveformGraphics.x = params.outputWaveformGraphicsX;
        outputWaveformGraphics.y = params.outputWaveformGraphicsY;
        inputWaveformGraphicsOne.scaleX = params.inputWaveformGraphicsOneWidth * waveformMultInverse;
        inputWaveformGraphicsOne.scaleY = params.inputWaveformGraphicsOneHeight * waveformMultInverse;
        inputWaveformGraphicsOne.x = params.inputWaveformGraphicsOneX;
        inputWaveformGraphicsOne.y = params.inputWaveformGraphicsOneY;
        inputWaveformGraphicsTwo.scaleX = params.inputWaveformGraphicsTwoWidth * waveformMultInverse; 
        inputWaveformGraphicsTwo.scaleY = params.inputWaveformGraphicsTwoHeight * waveformMultInverse; 
        inputWaveformGraphicsTwo.x = params.inputWaveformGraphicsTwoX;
        inputWaveformGraphicsTwo.y = params.inputWaveformGraphicsTwoY;
        inputPortOne.x = params.inputPortOneX;
        inputPortOne.y = params.inputPortOneY;
        inputPortTwo.x = params.inputPortTwoX;
        inputPortTwo.y = params.inputPortTwoY;
        outputPort.x = params.outputPortX;
        outputPort.y = params.outputPortY;
        handle.x = params.handleX;
        handle.y = params.handleY;
        dial.x = params.dialX;
        dial.y = params.dialY;
    }

    public function new(a: Bool, ?p: Object) {
        super(p);
        isAnd = a;

        if (isAnd)
            sprite = new Bitmap(Res.img.And.toTile().center(), this);
        else
            sprite = new Bitmap(Res.img.Or.toTile().center(), this);

        dial = new Dial(() -> {transformedWaveform.weight = dial.value/9;}, this);

        inputOneCol = colors[RNGManager.random(colors.length)];
        inputTwoCol = colors[RNGManager.random(colors.length)];
        outputCol = colors[RNGManager.random(colors.length)];

        transformedWaveform = new WaveformCombination(isAnd);

        outputWaveformGraphics = new Graphics(this);

        inputWaveformGraphicsOne = new Graphics(this);
        inputWaveformGraphicsOne.filter = new Group([new Glow(inputOneCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputWaveformGraphicsTwo = new Graphics(this);
        inputWaveformGraphicsTwo.filter = new Group([new Glow(inputTwoCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputPortOne = new Port(false, this);
        inputPortOne.onConnection = (w) -> {inputWaveformOne = w; transformedWaveform.sourceOne = w;};
        inputPortOne.onDisconnect = () -> {inputWaveformOne = null; transformedWaveform.sourceOne = null;};

        inputPortTwo = new Port(false, this);
        inputPortTwo.onConnection = (w) -> {inputWaveformTwo = w; transformedWaveform.sourceTwo = w;};
        inputPortTwo.onDisconnect = () -> {inputWaveformTwo = null; transformedWaveform.sourceTwo = null;};
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> {return transformedWaveform;};

        handle = new Handle(this);

        MessageManager.addListener(this);

        if (isAnd)
            fromJson(hxd.Res.data.And.entry);
        else
            fromJson(hxd.Res.data.Or.entry);
        updateGraphics();
    }

    public function update(dt:Float):Bool {
        totalTimeOne   += dt*0.5 + RNGManager.srand(0.01);
        totalTimeTwo   += dt*0.5 + RNGManager.srand(0.01);
        totalTimeThree += dt*0.5 + RNGManager.srand(0.01);
        
        inputWaveformGraphicsOne.clear();
        inputWaveformOne?.draw(inputWaveformGraphicsOne, totalTimeOne, inputOneCol);
        inputWaveformGraphicsTwo.clear();
        inputWaveformTwo?.draw(inputWaveformGraphicsTwo, totalTimeTwo, inputTwoCol);
        outputWaveformGraphics.clear();
        transformedWaveform?.draw(outputWaveformGraphics, totalTimeThree, outputCol);

        dial.update(dt);
        return false;
    }

	public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UpdateAnd)) {
            var params: UpdateAnd = cast(msg, UpdateAnd);
            if (!isAnd) return false;
            fromJson(params.json);
            updateGraphics();
        }
        if (Std.isOfType(msg, UpdateOr)) {
            var params: UpdateOr = cast(msg, UpdateOr);
            if (isAnd) return false;
            fromJson(params.json);
            updateGraphics();
        }
		return false;
	}
}