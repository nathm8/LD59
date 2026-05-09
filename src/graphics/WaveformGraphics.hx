package graphics;

import graphics.shaders.PeriodicAlphaShader;
import h2d.Graphics;
import utilities.Utilities.clamp;
import utilities.RNGManager;
import h2d.filter.Blur;
import gamelogic.Waveform;
import gamelogic.Updateable;
import hxd.Res;
import h2d.SpriteBatch;
import h2d.SpriteBatch.BatchElement;
import h2d.Object;

typedef ColourTuple = {
    var r: Float;
    var g: Float;
    var b: Float;
    var a: Float;
}

function colourTupleFromInt(c: Int): ColourTuple {
    var r = ((c >> 16) & 0xFF) / 255;
    var g = ((c >> 8) & 0xFF) / 255;
    var b = (c & 0xFF) / 255;
    return {r: r, g: g, b: b, a: 1.0};
}

class WaveformParticle extends BatchElement {

    var lifetime = 0.0;
    var lifetimeDenom = 1.0;
    var totalLifetime = 5.0;

    var startColour: ColourTuple;
    var endColour: ColourTuple;

    public function new(c: Int) {
        super(Res.img.Dot16.toTile().center());
        setColours(c);
        colourInterp(1);
    }

    public function setColours(c: Int) {
        startColour = colourTupleFromInt(c);
        endColour = {
            r: startColour.r* 0.5, 
            g: startColour.g* 0.5, 
            b: startColour.b* 0.5, 
            a: 0.01};
    }

    function colourInterp(ratio: Float) {
        ratio = clamp(ratio, 0, 1);
        r = startColour.r * ratio + endColour.r * (1.0 - ratio);
        g = startColour.g * ratio + endColour.g * (1.0 - ratio);
        b = startColour.b * ratio + endColour.b * (1.0 - ratio);
        a = startColour.a * ratio + endColour.a * (1.0 - ratio);
    }

    override function update(dt:Float): Bool {
        lifetime += dt;

        var u = lifetime/lifetimeDenom;
        var v = Math.pow(4, -6*u);

        colourInterp(v);

        return lifetime < totalLifetime;
    }
}

// var particleNum = 0;

class WaveformGraphics extends Object implements Updateable {
    
    var waveform: Waveform;
    var lines: Graphics;
    var batch: SpriteBatch;
    var totalTime = 0.0;
    var phaseMod = 0.0;
    var speed = 0.75;

    var colour: Int;
    public var width: Float;
    public var height: Float;

    public function new(w:Float, h: Float, c: Int, wave: Waveform, ?p: Object) {
        super(p);
        waveform = wave;
        colour = c;
        width = w;
        height = h;
        batch = new SpriteBatch(Res.img.Dot16.toTile().center(), this);
        batch.hasUpdate = true;
        batch.smooth = true;
        batch.tileWrap = true;

        lines = new Graphics(this);
        lines.addShader(new PeriodicAlphaShader());

        batch.filter = new Blur(60, 1.4);
    }
    
    
    public function update(dt: Float): Bool {
        var samples = 10;
        var phase_increment = 0.25;
        var noise_proc = 200; // chance of 1 in noise_proc
        var noise_amount = 0.1;

        for (_ in 0...samples) {
            totalTime += speed*dt/samples;
            if (totalTime > 1) {
                phaseMod += phase_increment;
                totalTime -= 1;
            }
            var p = new WaveformParticle(colour);
            p.x = totalTime % 1;
            p.y = waveform.sample(4*(totalTime % 1 + phaseMod));
            if (RNGManager.random(noise_proc) == 0) {
                p.y += RNGManager.srand(noise_amount);
                if (RNGManager.random(noise_proc) == 0)
                    p.x += RNGManager.srand(noise_amount);
            }
            if (RNGManager.random(noise_proc) == 0) {
                p.x += RNGManager.srand(noise_amount);
                if (RNGManager.random(noise_proc) == 0)
                    p.y += RNGManager.srand(noise_amount);
            }

            p.x *= width;
            p.y *= height;
            batch.add(p);
            // particleNum++;
        }

        var blur = cast(batch.filter, Blur);
        if (RNGManager.random(noise_proc) == 0)
            blur.radius = clamp(blur.radius + RNGManager.srand(1), 50, 80);
        if (RNGManager.random(noise_proc) == 0)
            blur.gain = clamp(blur.gain + RNGManager.srand(noise_amount), 1.1, 1.5);
            
        speed = clamp(speed + RNGManager.srand(noise_amount), 0.5, 1.0);

        lines.clear();
        waveform.draw(lines, width, height, 4*phaseMod, colour);

        return false;
    }
}