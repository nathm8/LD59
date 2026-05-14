package gamelogic;

import utilities.Polygons.OrPolgonCentred;
import utilities.Polygons.AndPolgonCentred;
import utilities.Polygons.getScaledPolygon;
import gamelogic.physics.PolygonalPhysicalGameObject;
import utilities.Vector2D;
import graphics.WaveformGraphics;
import gamelogic.Dial.OrDial;
import sound.SoundManager;
import sound.CustomSound;
import graphics.VolumeSlider;
import graphics.Handle;
import haxe.Json;
import hxd.Res;
import hxd.fs.FileEntry;
import h2d.Bitmap;
import h2d.Object;
import utilities.Utilities.colors;
import utilities.RNGManager;
import utilities.MessageManager;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import gamelogic.Waveform.WaveformCombination;

typedef CombinatorJson = {
    var inputWaveformGraphicsOneWidth: Int;
    var inputWaveformGraphicsOneHeight: Int;
    var inputWaveformGraphicsOneX: Float;
    var inputWaveformGraphicsOneY: Float;
    var inputWaveformGraphicsTwoWidth: Int;
    var inputWaveformGraphicsTwoHeight: Int;
    var inputWaveformGraphicsTwoX: Float;
    var inputWaveformGraphicsTwoY: Float;
    var outputWaveformGraphicsWidth: Int;
    var outputWaveformGraphicsHeight: Int;
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

    var sliderX: Float;
    var sliderY: Float;
}

class Combinator extends Object implements MessageListener
                                implements Updateable {
                                    
    var isAnd: Bool; // otherwise Or
    var sprite: Bitmap;
    var dial: Dial;
    var inputPortOne: Port;
    var inputPortTwo: Port;
    var outputPort: Port;
    
    var physics: PolygonalPhysicalGameObject;
    var handle: PhysicalHandle;

    var totalTimeOne = 0.0;
    var totalTimeTwo = 0.0;
    var totalTimeThree = 0.0;

    var transformedWaveform: WaveformCombination;

    var inputWaveformOne: Waveform;
    var inputWaveformTwo: Waveform;
    
    var inputWaveformGraphicsOne: WaveformGraphics;
    var inputWaveformGraphicsTwo: WaveformGraphics;
    var outputWaveformGraphics: WaveformGraphics;

    var inputOneCol: Int;
    var inputTwoCol: Int;
    var outputCol: Int;

    var params: CombinatorJson;

    var slider: VolumeSlider;
    var sound: CustomSound;    

    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    function updateGraphics() {
        outputWaveformGraphics.x = params.outputWaveformGraphicsX;
        outputWaveformGraphics.y = params.outputWaveformGraphicsY;
        outputWaveformGraphics.width = params.outputWaveformGraphicsWidth;
        outputWaveformGraphics.height = params.outputWaveformGraphicsHeight;
        inputWaveformGraphicsOne.x = params.inputWaveformGraphicsOneX;
        inputWaveformGraphicsOne.y = params.inputWaveformGraphicsOneY;
        inputWaveformGraphicsTwo.width = params.inputWaveformGraphicsTwoWidth;
        inputWaveformGraphicsTwo.height = params.inputWaveformGraphicsTwoHeight;
        inputWaveformGraphicsTwo.x = params.inputWaveformGraphicsTwoX;
        inputWaveformGraphicsTwo.y = params.inputWaveformGraphicsTwoY;
        inputWaveformGraphicsTwo.width = params.inputWaveformGraphicsTwoWidth;
        inputWaveformGraphicsTwo.height = params.inputWaveformGraphicsTwoHeight;
        inputPortOne.x = params.inputPortOneX;
        inputPortOne.y = params.inputPortOneY;
        inputPortTwo.x = params.inputPortTwoX;
        inputPortTwo.y = params.inputPortTwoY;
        outputPort.x = params.outputPortX;
        outputPort.y = params.outputPortY;
        handle.x = params.handleX;
        handle.y = params.handleY;
        if (!isAnd) {
            dial.x = params.dialX;
            dial.y = params.dialY;
        }
        slider.x = params.sliderX;
        slider.y = params.sliderY;
    }

    public function new(pos: Vector2D, a: Bool, ?p: Object) {
        super(p);
        isAnd = a;
        if (isAnd) {
            fromJson(hxd.Res.data.And.entry);
            sprite = new Bitmap(Res.img.And.toTile().center(), this);
            physics = new PolygonalPhysicalGameObject(new Vector2D(), getScaledPolygon(AndPolgonCentred), this);
        } else {
            fromJson(hxd.Res.data.Or.entry);
            sprite = new Bitmap(Res.img.Or.toTile().center(), this);
            physics = new PolygonalPhysicalGameObject(new Vector2D(), getScaledPolygon(OrPolgonCentred), this);
            dial = new OrDial(3, () -> {transformedWaveform.weight = dial.value/6;}, this);
        }
        
        transformedWaveform = new WaveformCombination(isAnd);
        
        var cols = RNGManager.randoms(colors.length, 3, true);
        outputWaveformGraphics = new WaveformGraphics(params.outputWaveformGraphicsWidth, params.outputWaveformGraphicsHeight, colors[cols[0]], () -> transformedWaveform, this);
        inputWaveformGraphicsOne = new WaveformGraphics(params.inputWaveformGraphicsOneWidth, params.inputWaveformGraphicsOneHeight, colors[cols[1]], () -> transformedWaveform.sourceOne, this);
        inputWaveformGraphicsTwo = new WaveformGraphics(params.inputWaveformGraphicsTwoWidth, params.inputWaveformGraphicsTwoHeight, colors[cols[2]], () -> transformedWaveform.sourceTwo, this);

        inputPortOne = new Port(false, this);
        inputPortOne.onConnection = (w) -> { inputWaveformOne = w; transformedWaveform.sourceOne = w; sound.reload(w); };
        inputPortOne.onDisconnect = () ->  { inputWaveformOne = null; transformedWaveform.sourceOne = null; sound.reload(null); };

        inputPortTwo = new Port(false, this);
        inputPortTwo.onConnection = (w) -> { inputWaveformTwo = w; transformedWaveform.sourceTwo = w; sound.reload(w); };
        inputPortTwo.onDisconnect = () ->  { inputWaveformTwo = null; transformedWaveform.sourceTwo = null; sound.reload(null); };
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> { slider.mute(); return transformedWaveform; };
        outputPort.onDisconnect = () -> { slider.restore(); };

        handle = new PhysicalHandle(physics.body, this);

        var sound_channel = SoundManager.addWaveform(transformedWaveform);
        sound = sound_channel.sound;
        slider = new VolumeSlider(sound_channel.channel, this);
        slider.mute();

        MessageManager.addListener(this);
        updateGraphics();
        physics.body.setPosition(pos);
    }

    public function update(dt:Float):Bool {
        var p: Vector2D = physics.body.getPosition();
        x = p.x; y = p.y;
        rotation = physics.body.getAngle();
        handle.update(dt);

        outputWaveformGraphics.update(dt);
        inputWaveformGraphicsOne.update(dt);
        inputWaveformGraphicsTwo.update(dt);
        dial?.update(dt);
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