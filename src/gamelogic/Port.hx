package gamelogic;

import h2d.col.Circle;
import utilities.Vector2D;
import hxd.Res;
import h2d.Bitmap;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import h2d.Object;

class Port extends Object implements MessageListener 
{
    public var isOutput: Bool;
    // output port callback
    public var getOutput: () -> Waveform;
    // input port var\callback
    public var waveform: Waveform;
    public var onConnection: (w: Waveform) -> Void;

    public var onDisconnect: () -> Void;

    public var isConnected(default, set) = false;

    var sprite: Bitmap;

    public function new(o:Bool, ?p: Object) {
        isOutput = o;
        super(p);

        sprite = new Bitmap(Res.img.CablePort.toTile().center(), this);

        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, CableHeadMoved)) {
            var params = cast(msg, CableHeadMoved);
            if (isConnected) return false;
            var cable_head = params.cableHead;
            var p: Vector2D = sprite.getAbsPos().getPosition();
            var q: Vector2D = cable_head.getAbsPos().getPosition();
            var c = new Circle(p.x - q.x, p.y - q.y, 35);
            if (cable_head.collider.collideCircle(c)) {
                isConnected = cable_head.snapTo(new Vector2D(sprite.x, sprite.y), this);
                // hack for tutorial progression, but shouldn't matter elsewhere
                if (isConnected) {
                    if (isOutput)
                        MessageManager.send(new SineConnected());
                    else
                        MessageManager.send(new OutputConnected());
                }
            }
        }
        return false;
    }

    function set_isConnected(value) {
        isConnected = value;
        if (!isConnected && onDisconnect != null)
            onDisconnect();
        return isConnected;
    }
}