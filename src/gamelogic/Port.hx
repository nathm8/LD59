package gamelogic;

import h2d.col.Matrix;
import h2d.col.Point;
import h2d.Graphics;
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
    public var onConnection: (w: Waveform) -> Void;
    public var onDisconnect: Void -> Void;

    // bit hacky, force connection recheck for the splitter memory edge case
    // set and unset in Cable
    public var forceRecheck: Void -> Void;

    public var isConnected(default, set) = false;

    var sprite: Bitmap;

    var graphics: Graphics;
    var graphics2: Graphics;

    public function new(o:Bool, ?p: Object) {
        isOutput = o;
        super(p);

        sprite = new Bitmap(Res.img.CablePort.toTile().center(), this);
        graphics = new Graphics(getScene());
        graphics.lineStyle(1, 0x0000FF);
        graphics.drawCircle(0, 0, 15);
        graphics.visible = false;
        graphics2 = new Graphics(getScene());

        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, CableHeadMoved)) {
            var params = cast(msg, CableHeadMoved);
            if (isConnected) return false;
            var cable_head = params.cableHead;
            var p = sprite.getAbsPos().getPosition();
            var c1 = new Circle(p.x, p.y, 15);
            var q = cable_head.getAbsPos().getPosition();
            var c2 = new Circle(q.x, q.y, 40);
            if (c2.collideCircle(c1)) {
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