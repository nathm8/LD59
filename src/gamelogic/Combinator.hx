package gamelogic;

import gamelogic.Dial.OrDial;
import sound.SoundManager;
import sound.CustomSound;
import graphics.VolumeSlider;
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
    var handle: Handle;

    var totalTimeOne = 0.0;
    var totalTimeTwo = 0.0;
    var totalTimeThree = 0.0;

    var transformedWaveform: WaveformCombination;

    var inputWaveformOne: Waveform;
    var inputWaveformTwo: Waveform;
    
    var inputWaveformGraphicsOne: Graphics;
    var inputWaveformGraphicsTwo: Graphics;
    var outputWaveformGraphics: Graphics;

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
        inputWaveformGraphicsOne.x = params.inputWaveformGraphicsOneX;
        inputWaveformGraphicsOne.y = params.inputWaveformGraphicsOneY;
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
        if (!isAnd) {
            dial.x = params.dialX;
            dial.y = params.dialY;
        }
        slider.x = params.sliderX;
        slider.y = params.sliderY;
    }

    public function new(a: Bool, ?p: Object) {
        super(p);
        isAnd = a;

        if (isAnd)
            sprite = new Bitmap(Res.img.And.toTile().center(), this);
        else
            sprite = new Bitmap(Res.img.Or.toTile().center(), this);

        if (!isAnd)
            dial = new OrDial(3, () -> {transformedWaveform.weight = dial.value/6;}, this);

        var cols = RNGManager.randoms(colors.length, 3, true);
        inputOneCol = colors[cols[0]];
        inputTwoCol = colors[cols[1]];
        outputCol = colors[cols[2]];

        transformedWaveform = new WaveformCombination(isAnd);

        outputWaveformGraphics = new Graphics(this);
        inputWaveformGraphicsOne = new Graphics(this);
        inputWaveformGraphicsTwo = new Graphics(this);

        inputPortOne = new Port(false, this);
        inputPortOne.onConnection = (w) -> { inputWaveformOne = w; transformedWaveform.sourceOne = w; sound.reload(); };
        inputPortOne.onDisconnect = () ->  { inputWaveformOne = null; transformedWaveform.sourceOne = null; sound.reload(); };

        inputPortTwo = new Port(false, this);
        inputPortTwo.onConnection = (w) -> { inputWaveformTwo = w; transformedWaveform.sourceTwo = w; sound.reload(); };
        inputPortTwo.onDisconnect = () ->  { inputWaveformTwo = null; transformedWaveform.sourceTwo = null; sound.reload(); };
        
        outputPort = new Port(true, this);
        outputPort.getOutput = () -> {return transformedWaveform;};

        handle = new Handle(this);

        var sound_channel = SoundManager.addWaveform(transformedWaveform);
        sound = sound_channel.sound;
        slider = new VolumeSlider(sound_channel.channel, this);

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
        inputWaveformOne?.draw(inputWaveformGraphicsOne, params.inputWaveformGraphicsOneWidth, params.inputWaveformGraphicsOneHeight, totalTimeOne, inputOneCol);
        inputWaveformGraphicsTwo.clear();
        inputWaveformTwo?.draw(inputWaveformGraphicsTwo, params.inputWaveformGraphicsTwoWidth, params.inputWaveformGraphicsTwoHeight, totalTimeTwo, inputTwoCol);
        outputWaveformGraphics.clear();
        transformedWaveform?.draw(outputWaveformGraphics, params.outputWaveformGraphicsWidth, params.outputWaveformGraphicsHeight, totalTimeThree, outputCol);

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