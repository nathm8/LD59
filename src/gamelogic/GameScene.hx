package gamelogic;

import box2D.collision.B2AABB;
import utilities.Vector2D;
import h2d.col.Point;
import h2d.Scene;
import hxd.Key;
import gamelogic.Waveform.Square;
import gamelogic.Waveform.Triangle;
import gamelogic.Waveform.Sine;
import gamelogic.Updateable;
import gamelogic.physics.PhysicalWorld;
import utilities.RNGManager;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {

    var updateables = new Array<Updateable>();
    var cameraScale = 1.0;
    var cameraMovingLeft = false;
    var cameraMovingRight = false;
    var cameraMovingDown = false;
    var cameraMovingUp = false;
    var edgeScrollDistance = 50;
    var middleMouseMoving = false;
    var prevX = 0.0;
    var prevY = 0.0;

    var cameraMinScale = 0.1;
    var cameraMaxScale = 1.0;
    var cameraBounds = 2500.0;

    public function new() {
        super();

        defaultSmooth = true;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
        camera.sync(ctx);

        MessageManager.addListener(this);

        updateables.push(new TargetOscilloscope(new Vector2D(400, -200), this));
    }
    
    public function update(dt:Float) {
        PhysicalWorld.update(dt);
        cameraControl();

        var to_remove = new Array<Updateable>();
        for (u in updateables)
            if (u.update(dt))
                to_remove.push(u);
        for (u in to_remove)
            updateables.remove(u);
    }

    public function receive(msg:Message):Bool {
        // camera controls
        if (Std.isOfType(msg, MouseWheel)) {
            var params = cast(msg, MouseWheel);
            if (params.event.wheelDelta > 0)
                cameraScale *= 0.9;
            else
                cameraScale *= 1.1;
            cameraScale = Math.min(Math.max(cameraMinScale, cameraScale), cameraMaxScale);
            camera.setScale(cameraScale, cameraScale);
        }
        if (Std.isOfType(msg, MouseMove)) {
            var params = cast(msg, MouseMove);

            // middle mouse movement
            if (middleMouseMoving) {
                camera.x -= (params.event.relX - prevX)/camera.scaleX;
                camera.y -= (params.event.relY - prevY)/camera.scaleY;
            }
            prevX = params.event.relX;
            prevY = params.event.relY;
        }
        if (Std.isOfType(msg, MousePush)) {
            var params = cast(msg, MousePush);
            var p = new Point(params.event.relX, params.event.relY);
            if (params.event.button == 2)
                middleMouseMoving = true;
        }
        if (Std.isOfType(msg, MouseRelease)) {
            var params = cast(msg, MouseRelease);
            if (params.event.button == 2)
                middleMouseMoving = false;
        }
        // components
        if (Std.isOfType(msg, SpawnComponent)) {
            var params = cast(msg, SpawnComponent);
            var amp = 1/8*(3 + RNGManager.random(3));
            var freq = 1/8*(3 + RNGManager.random(3));
            var pos = findSpawnLocation();
            if (pos == null) {
                trace("unable to find spawn location");
                return false;
            }
            if (params.componentName == "Wire")
                updateables.push(new Cable(pos, this));
            if (params.componentName == "Sine")
                updateables.push(new Oscilloscope(pos, new Sine(amp, freq), this));
            if (params.componentName == "Square")
                updateables.push(new Oscilloscope(pos, new Square(amp, freq), this));
            if (params.componentName == "Triangle")
                updateables.push(new Oscilloscope(pos, new Triangle(amp, freq), this));
            if (params.componentName == "And")
                updateables.push(new Combinator(pos, true, this));
            if (params.componentName == "Or")
                updateables.push(new Combinator(pos, false, this));
            if (params.componentName == "Invert")
                updateables.push(new Inverter(pos, this));
            if (params.componentName == "Split")
                updateables.push(new Splitter(pos, this));
            if (params.componentName == "Phase")
                updateables.push(new Phase(pos, this));
        }
        return false;
    }

    function findSpawnLocation(): Vector2D {
        // based off largest component size
        var bounds = new Vector2D(300, 300);
        var aabb = new B2AABB();
        var samples = 1000;
        for (i in 0...samples) {
            var t = 120*Math.PI*i/samples;
            var p = new Vector2D(10*t, 0).rotate(t);

            aabb.lowerBound = p - bounds;
            aabb.upperBound = p + bounds;
            var clear = true;
            var f = (fixture: Dynamic) -> {clear = false; return false;};
            PhysicalWorld.gameWorld.queryAABB(f, aabb);
            if (clear) return p;
        }
        return null;
    }

    function cameraControl() {
        // if (cameraMovingUp)
        //     camera.y -= 10/cameraScale;
        // if (cameraMovingDown)
        //     camera.y += 10/cameraScale;
        // if (cameraMovingRight)
        //     camera.x += 10/cameraScale;
        // if (cameraMovingLeft)
        //     camera.x -= 10/cameraScale;
        if (Key.isDown(Key.A))
			camera.move(-10/cameraScale,0);
		if (Key.isDown(Key.D))
			camera.move(10/cameraScale,0);
		if (Key.isDown(Key.W))
			camera.move(0,-10/cameraScale);
		if (Key.isDown(Key.S))
			camera.move(0,10/cameraScale);
		if (Key.isDown(Key.E))
			cameraScale *= 1.1;
		if (Key.isDown(Key.Q))
			cameraScale *= 0.9;
        cameraScale = Math.min(Math.max(cameraMinScale, cameraScale), cameraMaxScale);
        camera.setScale(cameraScale, cameraScale);

        if (camera.x < -cameraBounds)
            camera.x = -cameraBounds;
        if (camera.x > cameraBounds)
            camera.x = cameraBounds;
        if (camera.y < -cameraBounds)
            camera.y = -cameraBounds;
        if (camera.y > cameraBounds)
            camera.y = cameraBounds;
    }

}
