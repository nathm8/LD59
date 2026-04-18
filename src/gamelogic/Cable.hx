package gamelogic;

import utilities.MessageManager;
import h3d.Vector;
import utilities.Vector2D;
import utilities.MessageManager.MouseMove;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import hxd.Event;
import h2d.col.PixelsCollider;
import hxd.Res;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Interactive;
import h2d.Object;

class CableHead extends Object implements MessageListener {

    var sprite: Bitmap;
    public var interactive: Interactive;

    var isSelected = false;
    var lastPosition = new Vector2D();

    public var connection: Connectable;
    var cable: Cable;

    public function new(c: Cable, ?p: Object) {
        super();
        // ensure cable is always behind other sprites
        p.addChildAt(this, 0);
        
        cable = c;
        var t = Res.img.CableHead.toTile().center();
        sprite = new Bitmap(t, this);
        var pixels = new PixelsCollider(t.getTexture().capturePixels());
        interactive = new Interactive(t.width, t.height, this, pixels);
        interactive.x -= t.width/2;
        interactive.y -= t.height/2;

        interactive.onPush = (e:Event) -> {isSelected = true;}
        interactive.onRelease = (e:Event) -> {isSelected = false;}

        // var bounds = i.getBounds();
        // bounds.collideBounds();

        MessageManager.addListener(this);
    }


    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            x = params.scenePosition.x;
            y = params.scenePosition.y;
            var v = new Vector2D(x, y);
            rotation = (v - lastPosition).angle() + Math.PI/2;
            lastPosition = 0.99*lastPosition + 0.01*v;
            MessageManager.send(new CableHeadMoved(this));
        }
        return false;
    }

    public function snapTo(p: Vector2D, conn:Connectable) {
        x = p.x; y = p.y; rotation = conn.isOutput ? -Math.PI/2 : Math.PI/2;
        connection = conn;
        cable.newConnection();
    }

    public function getTail(): Vector2D {
        var h = sprite.getSize().height;
        var p: Vector2D = sprite.getAbsPos().getPosition();
        return p - new Vector2D(0, -h/2).rotate(rotation);
    }
}

class Cable implements Updateable {
    
    var headOne: CableHead;
    var headTwo: CableHead;
    var cable: Graphics;

    public function new(?p: Object) {
        headOne = new CableHead(this, p);
        headTwo = new CableHead(this, p);
        cable = new Graphics(p);
    }

    public function update(dt:Float):Bool {
        cable.clear();
        cable.lineStyle(10, 0x1A1A1A);
        var t = headOne.getTail();
        cable.moveTo(t.x, t.y);
        t = headTwo.getTail();
        cable.lineTo(t.x, t.y);
        return false;
    }

    public function newConnection() {
        if (headOne.connection != null && headTwo.connection != null) {
            if (headOne.connection.isOutput && !headTwo.connection.isOutput)
                headTwo.connection.newInput(headOne.connection.getWaveform());
            if (!headOne.connection.isOutput && headTwo.connection.isOutput)
                headOne.connection.newInput(headTwo.connection.getWaveform());
        }
    }
}