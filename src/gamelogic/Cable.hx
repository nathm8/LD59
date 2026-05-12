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
    var selectedOffset = new Vector2D();
    var lastPosition = new Vector2D();

    public var connectedPort: Port;
    var cable: Cable;

    var snapImmunity = 0.0;

    public function new(c: Cable, ?p: Object) {
        super(p);
        // ensure cable is always in front of other sprites
        getScene()?.over(this);
        
        cable = c;
        var t = Res.img.CableHead.toTile();
        sprite = new Bitmap(t, this);
        collider = new PixelsCollider(t.getTexture().capturePixels());
        interactive = new Interactive(0, 0, this, collider);

        var s = sprite.getSize();
        var h = s.height;
        var w = s.width;
        selectedOffset = new Vector2D(-w/2, -h/2);

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
            var p = selectedOffset.clone();
            p.rotate(rotation);
            x = params.scenePosition.x + p.x;
            y = params.scenePosition.y + p.y;
            var v = new Vector2D(x, y);
            rotation = (v - lastPosition).angle() + Math.PI/2;
            lastPosition = 0.99*lastPosition + 0.01*v;
            MessageManager.send(new CableHeadMoved(this));
        }
        return false;
    }

    public function snapTo(port: Port): Bool {
        if (snapImmunity > 0) return false;
        connectedPort = port;
        cable.newConnection();
        port.forceRecheck = cable.newConnection;
        isSelected = false;
        remove();
        port.parent.addChildAt(this, 0);

        rotation = port.isOutput ? -Math.PI/2 : Math.PI/2;
        rotation += port.rotation;
        var s = sprite.getSize();
        var offset = new Vector2D(s.width/2, s.height/2);
        offset.rotate(rotation);
        x = port.x - offset.x;
        y = port.y - offset.y;
        return true;
    }

    public function getTail(): Vector2D {
        var s = sprite.getSize();
        var h = s.height;
        var w = s.width;
        var p: Vector2D = sprite.getAbsPos().getPosition();
        return p - new Vector2D(-w/2, -h).rotate(rotation);
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
        getScene()?.over(this);
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