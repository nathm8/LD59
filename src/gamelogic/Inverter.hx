package gamelogic;

import sound.SoundManager;
import sound.CustomSound;
import graphics.VolumeSlider;
import graphics.Handle;
import haxe.Json;
import hxd.fs.FileEntry;
import h2d.filter.Blur;
import h2d.filter.Glow;
import h2d.filter.Group;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Object;
import hxd.Res;

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

    var sliderX: Float;
    var sliderY: Float;
}

class Inverter extends Object implements MessageListener
                              implements Updateable {

    var sprite: Bitmap;
    var inputPort: Port;
    var outputPort: Port;

    var totalTime = 0.0;

    var transformedWaveform: WaveformInverter;

    var inputWaveform: Waveform;
    
    var outputWaveformGraphics: Graphics;
    var outputCol: Int;

    var handle: Handle;

    var params: InverterJson;

    var slider: VolumeSlider;
    var sound: CustomSound;


    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    function updateGraphics() {
        outputWaveformGraphics.x = params.outputWaveformGraphicsX;
        outputWaveformGraphics.y = params.outputWaveformGraphicsY;
        inputPort.x = params.inputPortX;
        inputPort.y = params.inputPortY;
        outputPort.x = params.outputPortX;
        outputPort.y = params.outputPortY;
        handle.x = params.handleX;
        handle.y = params.handleY;
        slider.x = params.sliderX;
        slider.y = params.sliderY;
    }

    public function new(?p: Object) {
        super(p);

        sprite = new Bitmap(Res.img.Invert.toTile().center(), this);
        var size = sprite.getSize();

        outputCol = colors[RNGManager.random(colors.length)];

        transformedWaveform = new WaveformInverter();

        outputWaveformGraphics = new Graphics(this);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> { inputWaveform = w; transformedWaveform.source = w; sound.reload(); };
        inputPort.onDisconnect = () ->  { inputWaveform = null; transformedWaveform.source = null; sound.reload(); };
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> {return transformedWaveform;};

        handle = new Handle(this);

        var sound_channel = SoundManager.addWaveform(transformedWaveform);
        sound = sound_channel.sound;
        slider = new VolumeSlider(sound_channel.channel, this);

        MessageManager.addListener(this);
        fromJson(hxd.Res.data.Inverter.entry);
        updateGraphics();
    }

    public function update(dt:Float):Bool {
        totalTime += dt*0.5;
        outputWaveformGraphics.clear();
        transformedWaveform?.draw(outputWaveformGraphics, params.outputWaveformGraphicsWidth, params.outputWaveformGraphicsHeight, totalTime, outputCol);
        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UpdateInvert)) {
            var params: UpdateInvert = cast(msg, UpdateInvert);
            fromJson(params.json);
            updateGraphics();
        }
		return false;
	}
}