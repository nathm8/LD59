package gamelogic;

import utilities.Utilities.HANDLE_WIDTH;
import haxe.Json;
import hxd.fs.FileEntry;
import h2d.filter.Blur;
import h2d.filter.Glow;
import h2d.filter.Group;
import h2d.Interactive;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Object;
import hxd.Res;
import hxd.Event;
import gamelogic.Waveform.waveformMultInverse;
import gamelogic.Waveform.WaveformInverter;
import utilities.RNGManager;
import utilities.Utilities.colors;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;

typedef InverterJson = {
    var outputWaveformGraphicsWidth: Float;
    var outputWaveformGraphicsHeight: Float;
    var outputWaveformGraphicsX: Float;
    var outputWaveformGraphicsY: Float;

    var inputPortX: Float;
    var inputPortY: Float;
    var outputPortX: Float;
    var outputPortY: Float;

    var handleX: Float;
    var handleY: Float;
}

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

    var handle: Interactive;

    var params: InverterJson;


    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    function updateGraphics() {
        outputWaveformGraphics.scaleX = params.outputWaveformGraphicsWidth * waveformMultInverse;
        outputWaveformGraphics.scaleY = params.outputWaveformGraphicsHeight * waveformMultInverse;
        outputWaveformGraphics.x = params.outputWaveformGraphicsX;
        outputWaveformGraphics.y = params.outputWaveformGraphicsY;
        inputPort.x = params.inputPortX;
        inputPort.y = params.inputPortY;
        outputPort.x = params.outputPortX;
        outputPort.y = params.outputPortY;
        handle.x = params.handleX;
        handle.y = params.handleY;
    }

    public function new(?p: Object) {
        super(p);

        sprite = new Bitmap(Res.img.Invert.toTile().center(), this);
        var size = sprite.getSize();

        outputCol = colors[RNGManager.random(colors.length)];

        transformedWaveform = new WaveformInverter();

        outputWaveformGraphics = new Graphics(this);
        outputWaveformGraphics.filter = new Group([new Glow(outputCol, 1, 10, 1, 1, true), new Blur(60, 1.1)]);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> {inputWaveform = w; transformedWaveform.source = w;};
        inputPort.onDisconnect = () -> {inputWaveform = null; transformedWaveform.source = null;};
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> {return transformedWaveform;};

        handle = new Interactive(HANDLE_WIDTH, HANDLE_WIDTH, this);
        handle.onPush = (e:Event) -> {isSelected = true;}
        handle.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
        fromJson(hxd.Res.data.Inverter.entry);
        updateGraphics();
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
        if (Std.isOfType(msg, UpdateInvert)) {
            var params: UpdateInvert = cast(msg, UpdateInvert);
            fromJson(params.json);
            updateGraphics();
        }
		return false;
	}
}