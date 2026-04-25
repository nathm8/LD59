package gamelogic;

import utilities.RNGManager;
import h2d.Graphics;

final waveformMult = 500;
final waveformMultInverse = 1/waveformMult;

class Waveform {

    // period assumed to be 1.0
    public var amplitude:Float;
    public var frequency:Float;
    public var phase:Float;

    public function new(a=0.5, f=0.5, p=0.5) {
        amplitude = a;
        frequency = f;
        phase = p;
    }

    var previous: Waveform;

    static final drawing_samples = 1000;

    // t in [0,1]
    // return in [0,1]
    public function sample(t:Float, ?d:Int=0, ?sound=false):Float {return 0.5;}
    public function samplePreviousWeighted(t:Float, w:Float):Float {return 0.5;}

    public function draw(target:Graphics, ?phase_delta:Float, ?col:Int=0x00FF00, ?alpha:Float=0): Void {
        target.lineStyle(5, col);
        target.moveTo(0, samplePreviousWeighted(phase_delta, 0.1)*waveformMult);
        for (i in 0...drawing_samples) {
            var x = i/drawing_samples;
            var y = samplePreviousWeighted(x + phase_delta, 0.1);
            if (RNGManager.random(5000) == 0) {
                y += RNGManager.srand(0.1);
                if (RNGManager.random(1000) == 0)
                    x += RNGManager.srand(0.1);
            }
            if (RNGManager.random(5000) == 0) {
                x += RNGManager.srand(0.1);
                if (RNGManager.random(1000) == 0)
                    y += RNGManager.srand(0.1);
            }
            y = y < -0.5 ? -0.5: y > 0.5 ? 0.5 : y;
            target.lineTo(x*waveformMult, y*waveformMult);
        }
        // this lerp is framerate dependant on how many time draw is called, but it's a visual effect only so that's fine
        if (previous == null) return;
        previous.amplitude = 0.99*previous.amplitude + 0.01*amplitude;
        previous.frequency = 0.99*previous.frequency + 0.01*frequency;
        previous.phase     = 0.99*previous.phase + 0.01*phase;
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

    public function backup(): Void {};
}

class Sine extends Waveform {

    override public function backup() {
        previous = new Sine(amplitude, frequency, phase);
    }

    public static function staticSample(t:Float, a:Float, f:Float, p:Float):Float {
        t -= p*Math.PI;
        return 0.5*a*Math.sin( f*4*Math.PI*t );
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        return staticSample(t, amplitude, frequency, phase);
    }

    override public function samplePreviousWeighted(t:Float, w:Float):Float {
        if (previous == null)
            return sample(t);
        return w*Sine.staticSample(t, amplitude, frequency, phase) + (1-w)*Sine.staticSample(t, previous.amplitude, previous.frequency, previous.phase);
    }

}

function sign(v: Float): Int {
    if (v > 0)
        return 1;
    return -1;
}

class Square extends Waveform {

    override public function backup() {
        previous = new Square(amplitude, frequency, phase);
    }

    public static function staticSample(t:Float, a:Float, f:Float, p:Float, ?sound=false):Float {
        t -= p*Math.PI;
        // if (!sound)
        //     return 0.5*a*sign( Math.sin(f*4*Math.PI*t) );

        var out = 0.0;
        for (n in 1...26)
            out += 2*(1+Math.pow(-1, n+1))/(n*Math.PI) * Math.sin(4*f*n*Math.PI*t);
        return a*0.5*out;
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        return staticSample(t, amplitude, frequency, phase, sound);
    }

    override public function samplePreviousWeighted(t:Float, w:Float):Float {
        if (previous == null)
            return sample(t);
        return w*Square.staticSample(t, amplitude, frequency, phase) + (1-w)*Square.staticSample(t, previous.amplitude, previous.frequency, previous.phase);
    }
}

class Triangle extends Waveform {

    override public function backup() {
        previous = new Triangle(amplitude, frequency, phase);
    }

    public static function staticSample(t:Float, a:Float, f:Float, p:Float):Float {
        t -= p*Math.PI;
        return a/Math.PI*Math.asin( Math.sin(f*4*Math.PI*t) );
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        return staticSample(t, amplitude, frequency, phase);
    }

    override public function samplePreviousWeighted(t:Float, w:Float):Float {
        if (previous == null)
            return sample(t);
        return w*Triangle.staticSample(t, amplitude, frequency, phase) + (1-w)*Triangle.staticSample(t, previous.amplitude, previous.frequency, previous.phase);
    }
}

class WaveformCombination extends Waveform {

    public var sourceOne: Waveform;
    public var sourceTwo: Waveform;
    // [0, 1]
    public var weight = 8/9;

    var isAnd: Bool;

    public function new(a: Bool) {
        super();
        isAnd = a;
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        if (d == 100) return -0.5;
        if (sourceOne == null || sourceTwo == null) return -0.5;
        var y: Float;
        if (isAnd)
            y = 2*weight*sourceOne.sample(t, d+1)*sourceTwo.sample(t, d+1);
        else
            y = weight*sourceOne.sample(t, d+1) + (1 - weight)*sourceTwo.sample(t, d+1);
        y = y > 0.5 ? 0.5 : y < -0.5 ? -0.5 : y;
        return y;
    }

    override public function samplePreviousWeighted(t:Float, w:Float):Float {
        return sample(t);
    }
}

class WaveformInverter extends Waveform {

    public var source: Waveform;

    public function new() {
        super();
    }

    override public function sample(t:Float, ?d:Int=0, ?sound=false):Float {
        if (source == null) return 0.5;
        if (d == 100) return 0.5;
        return -source.sample(t, d+1);
    }

    override public function samplePreviousWeighted(t:Float, w:Float):Float {
        return sample(t);
    }
}