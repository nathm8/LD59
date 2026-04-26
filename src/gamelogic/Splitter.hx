package gamelogic;

import hxd.fs.FileEntry;
import haxe.Json;
import hxd.Event;
import hxd.Res;
import h2d.Interactive;
import h2d.Bitmap;
import h2d.Object;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;

typedef SplitterJson = {
    var inputPortX: Float;
    var inputPortY: Float;
    var outputPortOneX: Float;
    var outputPortOneY: Float;
    var outputPortTwoX: Float;
    var outputPortTwoY: Float;
    var handleX: Float;
    var handleY: Float;
}

class Splitter extends Object implements MessageListener
                              implements Updateable {

    var sprite: Bitmap;
    var inputPort: Port;
    var outputPortOne: Port;
    var outputPortTwo: Port;

    var waveform: Waveform;

    var isSelected = false;
    var handle: Interactive;

    var params: SplitterJson;

    function fromJson(j: FileEntry) {
        params = Json.parse(j.getText());
    }

    function updateGraphics() {
        inputPort.x = params.inputPortX;
        inputPort.y = params.inputPortY;
        outputPortOne.x = params.outputPortOneX;
        outputPortOne.y = params.outputPortOneY;
        outputPortTwo.x = params.outputPortTwoX;
        outputPortTwo.y = params.outputPortTwoY;
        handle.x = params.handleX;
        handle.y = params.handleY;
    }

    public function new(?p: Object) {
        super(p);

        sprite = new Bitmap(Res.img.Split.toTile().center(), this);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> {waveform = w;};
        inputPort.onDisconnect = () -> {waveform = null;};
        
        outputPortOne = new Port(true, this);
        outputPortOne.getOutput = () -> {return waveform;};

        outputPortTwo = new Port(true, this);
        outputPortTwo.getOutput = () -> {return waveform;};

        handle = new Interactive(141, 16, this);
        handle.onPush = (e:Event) -> {isSelected = true;}
        handle.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
        fromJson(hxd.Res.data.Splitter.entry);
        updateGraphics();
    }

    public function update(dt:Float):Bool {
        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            x = params.scenePosition.x;
            var size = sprite.getSize();
            y = params.scenePosition.y + size.height/2 - 12;
        }
		return false;
	}
}