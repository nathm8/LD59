package gamelogic;

import gamelogic.Waveform.Square;
import gamelogic.Waveform.Triangle;
import utilities.RNGManager;
import gamelogic.Waveform.Sine;
import hxd.Key;
import h2d.filter.Bloom;
import h2d.filter.Blur;
import h2d.Flow;
import h2d.Tile;
import h3d.mat.Texture;
import h2d.Bitmap;
import hxd.Res;
import h2d.filter.Glow;
import h2d.Graphics;
import h2d.col.Point;
import h2d.Scene;
import hxd.Window;
import gamelogic.Updateable;
import gamelogic.physics.PhysicalWorld;
import utilities.Vector2D;
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

        defaultSmooth = false;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
        camera.sync(ctx);

        MessageManager.addListener(this);

        // var o = new Oscilloscope(this);
        // o.x = -300;

        var target = new TargetOscilloscope(this);
        target.x = 400;
        target.y = -200;

        // var cables = new Cable(this);

        // updateables.push(o);
        updateables.push(target);
        // updateables.push(cables);
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
            var n = params.componentName;
            if (n == "Wire")
                updateables.push(new Cable(this));
            if (n == "Sine")
                updateables.push(new Oscilloscope(new Sine(1, 1, 1), this));
            if (n == "Square")
                updateables.push(new Oscilloscope(new Square(1, 1, 1), this));
            if (n == "Triangle")
                updateables.push(new Oscilloscope(new Triangle(1, 1, 1), this));
        }
        // graphics
        return false;
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
