package gamelogic;

import haxe.ds.Vector;
import utilities.RNGManager;
import h2d.Graphics;

final WAVEFORM_CACHE_LENGTH = 100;

class Waveform {

    // period assumed to be 1.0
    public var amplitude:Float;
    public var frequency:Float;

    public function new(a=0.5, f=0.5) {
        amplitude = a;
        frequency = f;
    }

    var cache: Vector<Float>;

    /**
        t in [0,1]
        return in [0,1]
    **/
    public function sample(t:Float, ?d:Int=0, ?sound=false):Float {return 0.5;}

    public function draw(target:Graphics, width:Float, height:Float, ?phase_delta:Float, ?col:Int=0x00FF00, ?drawing_samples=100): Void {
        target.lineStyle(5, col);
        target.moveTo(0, sample(phase_delta)*height);
        for (i in 0...drawing_samples) {
            var x = i/drawing_samples*4;
            var y = sample(x + phase_delta);
            if (RNGManager.random(2000) == 0) {
                y += RNGManager.srand(0.1);
                if (RNGManager.random(1000) == 0)
                    x += RNGManager.srand(0.1);
            }
            if (RNGManager.random(2000) == 0) {
                x += RNGManager.srand(0.1);
                if (RNGManager.random(1000) == 0)
                    y += RNGManager.srand(0.1);
            }
            y = y < -0.5 ? -0.5: y > 0.5 ? 0.5 : y;
            target.lineTo(x*.25*width, y*height);
        }
    }

    public function match(o: Waveform): Bool {
        final match_samples = 1000;
        final epsilon = 0.01;
        for (x in 0...match_samples) {
            if (Math.abs(sample(x/match_samples) - o.sample(x/match_samples)) > epsilon)
                return false;
        }
        return true;
    }
}

class Sine extends Waveform {

    public static function staticSample(t:Float, a:Float, f:Float):Float {
        return 0.5*a*Math.sin( f*4*Math.PI*t );
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        return staticSample(t, amplitude, frequency);
    }

}

function sign(v: Float): Int {
    if (v > 0)
        return 1;
    return -1;
}

class Square extends Waveform {

    public static function staticSample(t:Float, a:Float, f:Float, ?sound=false):Float {
        if (!sound)
            return 0.5*a*sign( Math.sin(f*4*Math.PI*t) );

        var out = 0.0;
        for (n in 1...26)
            out += 2*(1+Math.pow(-1, n+1))/(n*Math.PI) * Math.sin(4*f*n*Math.PI*t);
        return a*0.5*out;
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        return staticSample(t, amplitude, frequency, sound);
    }
}

class Triangle extends Waveform {

    public static function staticSample(t:Float, a:Float, f:Float):Float {
        return a/Math.PI*Math.asin( Math.sin(f*4*Math.PI*t) );
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        return staticSample(t, amplitude, frequency);
    }
}

class WaveformCombination extends Waveform {

    public var sourceOne: Waveform;
    public var sourceTwo: Waveform;
    // [0, 1], only used by Or
    public var weight = 0.5;

    var isAnd: Bool;

    public function new(a: Bool) {
        super();
        isAnd = a;
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        if (d == 100) return -1;
        if (sourceOne == null || sourceTwo == null || sourceOne.sample(0, d+1) == -1 || sourceTwo.sample(0, d+1) == -1) return -1;
        var y: Float;
        if (isAnd)
            y = sourceOne.sample(t, d+1)*sourceTwo.sample(t, d+1);
        else
            y = weight*sourceOne.sample(t, d+1) + (1 - weight)*sourceTwo.sample(t, d+1);
        y = y > 0.5 ? 0.5 : y < -0.5 ? -0.5 : y;
        return y;
    }

    override public function draw(target:Graphics, width:Float, height:Float, ?phase_delta:Float, ?col:Int=0x00FF00, ?drawing_samples=100): Void {
        if (sample(0) == -1) return;
        super.draw(target, width, height, phase_delta, col, drawing_samples);
    }
}

class WaveformInverter extends Waveform {

    public var source: Waveform;

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        if (d == 100) return -1;
        if (source == null || source.sample(0, d+1) == -1) return -1;
        return -source.sample(t, d+1);
    }

    override public function draw(target:Graphics, width:Float, height:Float, ?phase_delta:Float, ?col:Int=0x00FF00, ?drawing_samples=100): Void {
        if (sample(0) == -1) return;
        super.draw(target, width, height, phase_delta, col, drawing_samples);
    }
}