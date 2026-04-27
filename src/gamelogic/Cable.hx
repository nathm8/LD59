package gamelogic;

import h2d.col.Collider;
import utilities.RNGManager;
import utilities.MessageManager;
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
    public var collider: Collider;

    var isSelected = false;
    var lastPosition = new Vector2D();

    public var connectedPort: Port;
    var cable: Cable;

    var snapImmunity = 0.0;

    public function new(c: Cable, ?p: Object) {
        super();
        // ensure cable is always behind other sprites
        p.addChildAt(this, 0);
        
        cable = c;
        var t = Res.img.CableHead.toTile().center();
        sprite = new Bitmap(t, this);
        collider = new PixelsCollider(t.getTexture().capturePixels());
        interactive = new Interactive(0, 0, this, collider);
        interactive.x -= t.width/2;
        interactive.y -= t.height/2;

        interactive.onPush = (e:Event) -> {
            disconnect();
            isSelected = true;
        }
        interactive.onRelease = (e:Event) -> {
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

    public function snapTo(pos: Vector2D, port: Port): Bool {
        if (snapImmunity > 0) return false;
        connectedPort = port;
        cable.newConnection();
        port.forceRecheck = cable.newConnection;
        isSelected = false;
        remove();
        port.parent.addChildAt(this, 0);
        x = port.x + pos.x; y = port.y + pos.y;
        rotation = port.isOutput ? -Math.PI/2 : Math.PI/2;
        return true;
    }

    public function getTail(): Vector2D {
        var h = sprite.getSize().height;
        var p: Vector2D = sprite.getAbsPos().getPosition();
        return p - new Vector2D(0, -h/2).rotate(rotation);
    }

    function disconnect() {
        snapImmunity = 0.25;
        if (connectedPort != null) {
            connectedPort.isConnected = false;
            connectedPort.forceRecheck = null;
        }
        connectedPort = null;
        cable.disconnect();
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
        cable = new Graphics(p);
        headOne = new CableHead(this, p);
        headOne.x -= 25 - RNGManager.random(25);
        headOne.y+= -25 + RNGManager.random(50);
        headTwo = new CableHead(this, p);
        headTwo.x += 25 + RNGManager.random(25);
        headTwo.y+= -25 + RNGManager.random(50);
    }

    public function update(dt:Float):Bool {
        headOne.update(dt);
        headTwo.update(dt);

        cable.clear();
        cable.lineStyle(10, 0x1A1A1A);
        var t = headOne.getTail();
        cable.moveTo(t.x, t.y);
        var control = new Vector2D(t.x, t.y);
        t = headTwo.getTail();
        control = 0.5*(control + new Vector2D(t.x, t.y));
        control.y += headOne.getTail().distanceTo(headTwo.getTail());
        cable.curveTo(control.x, control.y, t.x, t.y);
        return false;
    }

    public function newConnection() {
        if (headOne.connectedPort != null && headTwo.connectedPort != null) {
            if (headOne.connectedPort.isOutput && !headTwo.connectedPort.isOutput) {
                headTwo.connectedPort.onConnection( headOne.connectedPort.getOutput() );
            }
            if (!headOne.connectedPort.isOutput && headTwo.connectedPort.isOutput) {
                headOne.connectedPort.onConnection( headTwo.connectedPort.getOutput() );
            }
        }
    }

    public function disconnect() {
        if (headOne.connectedPort != null && headOne.connectedPort.onDisconnect != null)
            headOne.connectedPort.onDisconnect();
        if (headTwo.connectedPort != null && headTwo.connectedPort.onDisconnect != null)
            headTwo.connectedPort.onDisconnect();
    }
}