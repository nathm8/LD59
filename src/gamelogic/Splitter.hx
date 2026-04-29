package gamelogic;

import haxe.Json;
import hxd.fs.FileEntry;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;
import graphics.Handle;
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

    var handle: Handle;

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

    // moar hacks :(
    // temporarily null forceRecheck before calling it, to prevent stackoverflow between `Cable.newConnection` and `Port.onConnect`
    function recursionBreaker(p: Port) {
        if (p.forceRecheck == null) return;
        var f = p.forceRecheck;
        p.forceRecheck = null;
        f();
        p.forceRecheck = f;
    }

    public function new(?p: Object) {
        super(p);

        sprite = new Bitmap(Res.img.Split.toTile().center(), this);

        inputPort = new Port(false, this);
        inputPort.onConnection = (w) -> {
            waveform = w;
            recursionBreaker(outputPortOne);
            recursionBreaker(outputPortTwo);
        };
        inputPort.onDisconnect = () -> {
            waveform = null;
            recursionBreaker(outputPortOne);
            recursionBreaker(outputPortTwo);
        };
        
        outputPortOne = new Port(true, this);
        outputPortOne.rotation = Math.PI/2;
        outputPortOne.getOutput = () -> {return waveform;};
        
        outputPortTwo = new Port(true, this);
        outputPortTwo.rotation = Math.PI/2;
        outputPortTwo.getOutput = () -> {return waveform;};

        handle = new Handle(this);

        MessageManager.addListener(this);
        fromJson(hxd.Res.data.Splitter.entry);
        updateGraphics();
    }

    public function update(dt:Float):Bool {
        return false;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, UpdateSplitter)) {
            var params: UpdateSplitter = cast(msg, UpdateSplitter);
            fromJson(params.json);
            updateGraphics();
        }
		return false;
	}
}