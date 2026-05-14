package gamelogic;

import utilities.Vector2D;
import graphics.WaveformGraphics;
import gamelogic.Waveform.WaveformPhase;
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

typedef PhaseJson = {
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

    var dialX: Float;
    var dialY: Float;
}

class Phase extends Object implements MessageListener
                           implements Updateable {

    var params: PhaseJson;

    var sprite: Bitmap;
    var inputPort: Port;
    var outputPort: Port;
    var waveformGraphics: WaveformGraphics;
    var dial: Dial;
    var handle: Handle;
    var slider: VolumeSlider;

    var transformedWaveform: WaveformPhase;
    var inputWaveform: Waveform;
    
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
        dial.x = params.dialX;
        dial.y = params.dialY;
    }

    public function new(pos: Vector2D, ?p: Object) {
        super(p);
        fromJson(hxd.Res.data.Phase.entry);

        sprite = new Bitmap(Res.img.Phase.toTile().center(), this);

        transformedWaveform = new WaveformPhase(0.0);

        waveformGraphics = new WaveformGraphics(params.waveformGraphicsWidth, params.waveformGraphicsHeight, colors[RNGManager.random(colors.length)], () -> transformedWaveform, this);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> { inputWaveform = w; transformedWaveform.source = w; sound.reload(w); };
        inputPort.onDisconnect = () ->  { inputWaveform = null; transformedWaveform.source = null; sound.reload(null); };
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> { slider.mute(); return transformedWaveform; };
        outputPort.onDisconnect = () -> { slider.restore(); };

        handle = new Handle(this);
        dial = new Dial(0, () -> { transformedWaveform.phase = dial.value/8;  sound.reload(transformedWaveform); }, sprite);

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
        if (Std.isOfType(msg, UpdatePhase)) {
            var params: UpdatePhase = cast(msg, UpdatePhase);
            fromJson(params.json);
            updateGraphics();
        }
		return false;
	}
}