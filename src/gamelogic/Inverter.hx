package gamelogic;

import utilities.Vector2D;
import graphics.WaveformGraphics;
import sound.SoundManager;
import sound.CustomSound;
import graphics.VolumeSlider;
import graphics.Handle;
import haxe.Json;
import hxd.fs.FileEntry;
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
    var waveformGraphicsWidth: Int;
    var waveformGraphicsHeight: Int;
    var waveformGraphicsX: Float;
    var waveformGraphicsY: Float;

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

    var params: InverterJson;

    var sprite: Bitmap;
    var inputPort: Port;
    var outputPort: Port;
    var handle: Handle;
    var waveformGraphics: WaveformGraphics;
    var slider: VolumeSlider;
    
    var inputWaveform: Waveform;
    var transformedWaveform: WaveformInverter;

    var sound: CustomSound;

    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    function updateGraphics() {
        waveformGraphics.x = params.waveformGraphicsX;
        waveformGraphics.y = params.waveformGraphicsY;
        waveformGraphics.width = params.waveformGraphicsWidth;
        waveformGraphics.height = params.waveformGraphicsHeight;
        inputPort.x = params.inputPortX;
        inputPort.y = params.inputPortY;
        outputPort.x = params.outputPortX;
        outputPort.y = params.outputPortY;
        handle.x = params.handleX;
        handle.y = params.handleY;
        slider.x = params.sliderX;
        slider.y = params.sliderY;
    }

    public function new(pos: Vector2D, ?p: Object) {
        super(p);
        fromJson(hxd.Res.data.Inverter.entry);

        sprite = new Bitmap(Res.img.Invert.toTile().center(), this);

        transformedWaveform = new WaveformInverter();
        
        waveformGraphics = new WaveformGraphics(params.waveformGraphicsWidth, params.waveformGraphicsHeight, colors[RNGManager.random(colors.length)], () -> transformedWaveform, this);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> { inputWaveform = w; transformedWaveform.source = w; sound.reload(w); };
        inputPort.onDisconnect = () ->  { inputWaveform = null; transformedWaveform.source = null; sound.reload(null); };
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> { slider.mute(); return transformedWaveform; };
        outputPort.onDisconnect = () -> { slider.restore(); };

        handle = new Handle(this);

        var sound_channel = SoundManager.addWaveform(transformedWaveform);
        sound = sound_channel.sound;
        slider = new VolumeSlider(sound_channel.channel, this);
        slider.mute();

        MessageManager.addListener(this);
        updateGraphics();
    }

    public function update(dt:Float):Bool {
        waveformGraphics.update(dt);
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