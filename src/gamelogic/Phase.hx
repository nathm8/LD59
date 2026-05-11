package gamelogic;

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
    var waveformGraphicsWidth: Float;
    var waveformGraphicsHeight: Float;
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

    var sprite: Bitmap;
    var inputPort: Port;
    var outputPort: Port;

    var totalTime = 0.0;

    var transformedWaveform: WaveformPhase;

    var inputWaveform: Waveform;
    
    var waveformGraphics: Graphics;
    var outputCol: Int;

    var handle: Handle;
    var dial: Dial;

    var params: PhaseJson;

    var slider: VolumeSlider;
    var sound: CustomSound;


    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    function updateGraphics() {
        waveformGraphics.x = params.waveformGraphicsX;
        waveformGraphics.y = params.waveformGraphicsY;
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

    public function new(?p: Object) {
        super(p);

        sprite = new Bitmap(Res.img.Phase.toTile().center(), this);
        var size = sprite.getSize();

        outputCol = colors[RNGManager.random(colors.length)];

        transformedWaveform = new WaveformPhase(0.0);

        waveformGraphics = new Graphics(this);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> { inputWaveform = w; transformedWaveform.source = w; sound.reload(); };
        inputPort.onDisconnect = () ->  { inputWaveform = null; transformedWaveform.source = null; sound.reload(); };
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> { slider.mute(); return transformedWaveform; };
        outputPort.onDisconnect = () -> { slider.restore(); };

        handle = new Handle(this);
        dial = new Dial(0, () -> { transformedWaveform.phase = dial.value/8;  sound.reload(); }, sprite);

        var sound_channel = SoundManager.addWaveform(transformedWaveform);
        sound = sound_channel.sound;
        slider = new VolumeSlider(sound_channel.channel, this);
        slider.mute();

        MessageManager.addListener(this);
        fromJson(hxd.Res.data.Phase.entry);
        updateGraphics();
    }

    public function update(dt:Float):Bool {
        totalTime += dt*0.5;
        waveformGraphics.clear();
        transformedWaveform?.draw(waveformGraphics, params.waveformGraphicsWidth, params.waveformGraphicsHeight, totalTime, outputCol);
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