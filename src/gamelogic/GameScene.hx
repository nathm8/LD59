package gamelogic;

import graphics.shaders.WaveformShader;
import graphics.shaders.PeriodicAlphaShader;
import h2d.Graphics;
import graphics.WaveformGraphics;
import h2d.filter.Group;
import h2d.filter.Bloom;
import h2d.filter.Blur;
import h2d.filter.Shader;
import h2d.col.Point;
import h2d.Scene;
import h2d.Tile;
import h2d.Bitmap;
import hxd.Key;
import hxsl.Types.Vec4;
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

    var w: Waveform;

    public function new() {
        super();

        defaultSmooth = true;
        camera.anchorX = 0.5;
        camera.anchorY = 0.5;
        camera.sync(ctx);

        MessageManager.addListener(this);

        // var target = new TargetOscilloscope(this);
        // target.x = 400;
        // target.y = -200;
        // updateables.push(target);

        var square = new Bitmap(Tile.fromColor(0x000000, 500, 500, 0), this);
        square.x -= 250; square.y -= 250;

        w = new Sine(1,1,1);
        var ws = new WaveformShader();
        ws.samples = new Array<Vec4>();
        var samples = 500;
        for (x in 0...samples) {
            ws.samples[x] = new Vec4(
                    0.5*(Math.sin(2*Math.PI * x/samples)) + 0.5
                , 0, 0, 0);
        }

        square.addShader(ws);
        square.addShader(new PeriodicAlphaShader());
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
            var amp = 1/8*(3 + RNGManager.random(3));
            var freq = 1/8*(3 + RNGManager.random(3));
            var phase = 1/8*(3 + RNGManager.random(3));
            if (n == "Wire")
                updateables.push(new Cable(this));
            if (n == "Sine")
                updateables.push(new Oscilloscope(new Sine(amp, freq, phase), this));
            if (n == "Square")
                updateables.push(new Oscilloscope(new Square(amp, freq, phase), this));
            if (n == "Triangle")
                updateables.push(new Oscilloscope(new Triangle(amp, freq, phase), this));
            if (n == "And")
                updateables.push(new Combinator(true, this));
            if (n == "Or")
                updateables.push(new Combinator(false, this));
            if (n == "Invert")
                updateables.push(new Inverter(this));
            if (n == "Split")
                updateables.push(new Splitter(this));
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
