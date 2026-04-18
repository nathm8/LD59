package gamelogic;

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
    var cameraBounds = 5000.0;

    public function new() {
        super();

        defaultSmooth = false;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
        camera.sync(ctx);

        MessageManager.addListener(this);

        var o = new Oscilloscope(this);
        o.x = -300;

        var target = new TargetOscilloscope(this);
        // target.inputWaveform = o.waveform;
        target.x = 300;
        target.y = 300;

        var cables = new Cable(this);

        updateables.push(o);
        updateables.push(target);
        updateables.push(cables);
    }
    
    public function update(dt:Float) {
        PhysicalWorld.update(dt);
        // cameraControl();
        
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
            else {
                // change anchor for zooming
                var prevAbsX = camera.absX;
                var prevAbsY = camera.absY;
                camera.anchorX = params.event.relX / Window.getInstance().width;
                camera.anchorY = params.event.relY / Window.getInstance().height;
                camera.sync(ctx, true);
                var x_diff = prevAbsX - camera.absX;
                var y_diff = prevAbsY - camera.absY;
                camera.x -= x_diff/camera.scaleX;
                camera.y -= y_diff/camera.scaleY;
                camera.sync(ctx, true);
            }
            prevX = params.event.relX;
            prevY = params.event.relY;
            
            // edge scroll
            if (params.event.relX < 0 || params.event.relY < 0 || params.event.relX > Window.getInstance().width || params.event.relY > Window.getInstance().height) {
                cameraMovingLeft = false;
                cameraMovingRight = false;
                cameraMovingUp = false;
                cameraMovingDown = false;
            } else {
                cameraMovingLeft = params.event.relX < edgeScrollDistance;
                cameraMovingRight = params.event.relX > Window.getInstance().width - edgeScrollDistance;
                cameraMovingUp = params.event.relY < edgeScrollDistance;
                cameraMovingDown = params.event.relY > Window.getInstance().height - edgeScrollDistance;
            }
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
        // graphics
        return false;
    }

    function cameraControl() {
        if (cameraMovingUp)
            camera.y -= 10/cameraScale;
        if (cameraMovingDown)
            camera.y += 10/cameraScale;
        if (cameraMovingRight)
            camera.x += 10/cameraScale;
        if (cameraMovingLeft)
            camera.x -= 10/cameraScale;
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
