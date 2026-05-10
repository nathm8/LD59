package gamelogic;

import hxd.Res;
import h2d.Bitmap;
import h2d.Object;
import h2d.col.Circle;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;

class Port extends Object implements MessageListener 
{
    public var isOutput: Bool;
    // output port callback
    public var getOutput: () -> Waveform;
    // input port var\callback
    public var onConnection: (w: Waveform) -> Void;
    public var onDisconnect: Void -> Void;

    // bit hacky, force connection recheck for the splitter memory edge case
    // set and unset in Cable
    public var forceRecheck: Void -> Void;

    public var isConnected(default, set) = false;

    var sprite: Bitmap;

    public function new(o:Bool, ?p: Object) {
        super(p);
        isOutput = o;

        sprite = new Bitmap(Res.img.CablePort.toTile().center(), this);

        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, CableHeadMoved)) {
            var params = cast(msg, CableHeadMoved);
            if (isConnected) return false;
            var cable_head = params.cableHead;
            var p = sprite.getAbsPos().getPosition();
            var q = cable_head.globalToLocal(p);
            var c1 = new Circle(q.x, q.y, 15);
            
            if (cable_head.collider.collideCircle(c1)) {
                isConnected = cable_head.snapTo(this);
                // hack for tutorial progression, but shouldn't matter elsewhere
                if (isConnected) {
                    if (isOutput)
                        MessageManager.send(new SineConnected());
                    else
                        MessageManager.send(new OutputConnected());
                    return true;
                }
            }
        }
        return false;
    }

    function set_isConnected(value) {
        if (isConnected && !value && onDisconnect != null)
            onDisconnect();
        isConnected = value;
        return isConnected;
    }
}