package gamelogic;

import utilities.RNGManager;
import h2d.Graphics;

interface Waveform {
    // period assumed to be 1.0

    public var amplitude:Float;
    public var frequency:Float;
    public var phase:Float;

    // t in [0,1]
    // return in [0,1]
    public function sample(t: Float): Float;

    public function draw(target: Graphics, ?phase_delta: Float, ?col: Int): Void;

    public function match(o: Waveform): Bool;

    public function backup(): Void;
}

function defaultMatch(lhs: Waveform, rhs: Waveform) : Bool {
    final match_samples = 1000;
    final epsilon = 0.01;
    for (x in 0...match_samples) {
        if (Math.abs(lhs.sample(x/match_samples) - rhs.sample(x/match_samples)) > epsilon)
            return false;
    }
    return true;
}

class Sine implements Waveform {

	public var amplitude:Float;
	public var frequency:Float;
	public var phase:Float;

    var previous: Sine;

    public function new(a=0.5, f=0.5, p=0.5) {
        amplitude = a;
        frequency = f;
        phase = p;
    }

    public function backup() {
        previous = new Sine(amplitude, frequency, phase);
    }

    public static function staticSample(t:Float, a:Float, f:Float, p:Float):Float {
        return 0.5*a*Math.sin( f*4*Math.PI*t - p*Math.PI );
    }

    public function sample(t:Float):Float {
        return Sine.staticSample(t, amplitude, frequency, phase);
    }

    public function samplePreviousWeighted(t:Float, w:Float):Float {
        if (previous == null)
            return sample(t);
        return w*Sine.staticSample(t, amplitude, frequency, phase) + (1-w)*Sine.staticSample(t, previous.amplitude, previous.frequency, previous.phase);
    }

    public function draw(target:Graphics, ?phase_delta:Float, ?col:Int=0x00FF00): Void {
        final drawing_samples = 1000;
        target.lineStyle(0.01, col);
        target.moveTo(0, samplePreviousWeighted(phase_delta, 0.1));
        for (i in 0...drawing_samples) {
            var x = i/drawing_samples;
            var y = samplePreviousWeighted(x + phase_delta, 0.1);
            y += RNGManager.srand(0.001);
            if (RNGManager.random(10000) == 0) {
                y += RNGManager.srand(0.1);
            }
            y = y < -0.5 ? -0.5: y > 0.5 ? 0.5 : y;
            target.lineTo(x, y);
        }
        // this lerp is framerate dependant on how many time draw is called, but it's a visual effect only so that's fine
        if (previous == null) return;
        previous.amplitude = 0.99*previous.amplitude + 0.01*amplitude;
        previous.frequency = 0.99*previous.frequency + 0.01*frequency;
        previous.phase     = 0.99*previous.phase + 0.01*phase;
    }

    public function match(o:Waveform):Bool {
        return defaultMatch(this, o);
    }
}