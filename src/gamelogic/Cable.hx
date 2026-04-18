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

class CableHead extends Object implements MessageListener implements Updateable {

    var sprite: Bitmap;
    public var interactive: Interactive;

    var isSelected = false;
    var lastPosition = new Vector2D();

    public var connection: Connectable;
    var cable: Cable;

    var connectionPromise: () -> {pos: Vector2D, object: Object};
    var snapImmunity = 0.0;

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

        interactive.onPush = (e:Event) -> {
            disconnect();
            isSelected = true;
        }
        interactive.onRelease = (e:Event) -> {
            if (isSelected) reparent();
            isSelected = false;
        }

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

    public function snapTo(p: Vector2D, conn:Connectable, promise: () -> {pos: Vector2D, object: Object}) {
        if (snapImmunity > 0) return;
        x = p.x; y = p.y; rotation = conn.isOutput ? -Math.PI/2 : Math.PI/2;
        connectionPromise = promise;
        connection = conn;
        cable.newConnection();
    }
    
    public function reparent() {
        if (connectionPromise == null) return;
        var p = connectionPromise().pos;
        var o = connectionPromise().object;
        remove();
        o.addChildAt(this, 0);
        x = p.x; y = p.y; rotation = connection.isOutput ? -Math.PI/2 : Math.PI/2;
    }

    public function getTail(): Vector2D {
        var h = sprite.getSize().height;
        var p: Vector2D = sprite.getAbsPos().getPosition();
        return p - new Vector2D(0, -h/2).rotate(rotation);
    }

    function disconnect() {
        snapImmunity = 0.1;
        connectionPromise = null;
        cable.disconnect();
        connection = null;
        var s = getScene();
        var p = getAbsPos().getPosition();
        remove();
        s.addChildAt(this, 0);
        x = p.x; y = p.y;
    }

    public function update(dt:Float):Bool {
        if (snapImmunity > 0)
            snapImmunity -= dt;
        return false;
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
        headOne.update(dt);
        headTwo.update(dt);

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
                headTwo.connection.newInput(headOne.connection);
            if (!headOne.connection.isOutput && headTwo.connection.isOutput)
                headOne.connection.newInput(headTwo.connection);
        }
    }

    public function disconnect() {
        headTwo.connection?.disconnect(headOne.connection);
        headOne.connection?.disconnect(headTwo.connection);
    }
}