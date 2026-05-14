package gamelogic;

import utilities.Vector2D;
import gamelogic.physics.PolygonalPhysicalGameObject;
import utilities.Polygons.OscilloPolgonCentred;
import utilities.Polygons.getScaledPolygon;
import graphics.WaveformGraphics;
import sound.CustomSound;
import sound.SoundManager;
import graphics.VolumeSlider;
import graphics.Handle;
import haxe.Json;
import hxd.fs.FileEntry;
import hxd.Res;
import h2d.Object;
import h2d.Bitmap;

import utilities.Utilities.colors;
import utilities.RNGManager;
import utilities.MessageManager;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;

typedef OscilloscopeJson = {
    var ampDialX: Float;
    var ampDialY: Float;
    var freqDialX: Float;
    var freqDialY: Float;
    var phaseDialX: Float;
    var phaseDialY: Float;

    var waveformGraphicsWidth: Int;
    var waveformGraphicsHeight: Int;
    var waveformGraphicsX: Float;
    var waveformGraphicsY: Float;

    var portX: Float;
    var portY: Float;

    var handleX: Float;
    var handleY: Float;

    var sliderX: Float;
    var sliderY: Float;
}

class Oscilloscope extends Object implements Updateable
                                  implements MessageListener {
    
    var params: OscilloscopeJson;

    var physics: PolygonalPhysicalGameObject;

    public var waveform: Waveform;
    var waveformGraphics: WaveformGraphics;

    var sprite: Bitmap;
    var handle: PhysicalHandle;
    var ampDial: Dial;
    var freqDial: Dial;
    var port: Port;
    var slider: VolumeSlider;
    var sound: CustomSound;
    
    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    public function new(pos: Vector2D, w: Waveform, p: Object) {
        super(p);
        fromJson(hxd.Res.data.Oscilloscope.entry);

        physics = new PolygonalPhysicalGameObject(new Vector2D(), getScaledPolygon(OscilloPolgonCentred), this);

        waveform = w;

        sprite = new Bitmap(Res.img.Oscillo.toTile().center(), this);
        ampDial   = new Dial(Math.round(waveform.amplitude*8), () -> { waveform.amplitude = ampDial.value/8;  sound.reload(waveform); }, sprite);
        freqDial  = new Dial(Math.round(waveform.frequency*8), () -> { waveform.frequency = freqDial.value/8; sound.reload(waveform); }, sprite);

        var col = colors[RNGManager.random(colors.length)];
        waveformGraphics = new WaveformGraphics(params.waveformGraphicsWidth, params.waveformGraphicsHeight, col, () -> waveform, this);
        
        port = new Port(true, this);
        port.getOutput = () -> {slider.mute(); return waveform;};
        port.onDisconnect = () -> {slider.restore();};
        
        handle = new PhysicalHandle(physics.body, this);

        var sound_channel = SoundManager.addWaveform(waveform);
        sound = sound_channel.sound;
        slider = new VolumeSlider(sound_channel.channel, this);
        
        MessageManager.addListener(this);
        updateGraphics();
        physics.body.setPosition(pos);
    }
    
    function updateGraphics() {
        ampDial.x = params.ampDialX;
        ampDial.y = params.ampDialY;
        freqDial.x = params.freqDialX;
        freqDial.y = params.freqDialY;
        waveformGraphics.x = params.waveformGraphicsX;
        waveformGraphics.y = params.waveformGraphicsY;
        waveformGraphics.width = params.waveformGraphicsWidth;
        waveformGraphics.height = params.waveformGraphicsHeight;
        port.x = params.portX;
        port.y = params.portY;
        handle.x = params.handleX;
        handle.y = params.handleY;
        slider.x = params.sliderX;
        slider.y = params.sliderY;
    }

    public function update(dt:Float):Bool {
        var p: Vector2D = physics.body.getPosition();
        x = p.x; y = p.y;
        rotation = physics.body.getAngle();

        handle.update(dt);
        waveformGraphics.update(dt);
        ampDial.update(dt);
        freqDial.update(dt);
        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UpdateOscilloscope)) {
            var params: UpdateOscilloscope = cast(msg, UpdateOscilloscope);
            fromJson(params.json);
            updateGraphics();
        }
        return false;
    }
    
}