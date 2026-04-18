package gamelogic;

import utilities.RNGManager;
import h2d.Graphics;

interface Waveform {
    // period assumed to be 1.0

    public var amplitude: Float;
    public var frequency: Float;
    public var phase: Float;

    // t in [0,1]
    // return in [0,1]
    public function sample(t: Float): Float;

    public function draw(target: Graphics, ?phase_delta: Float): Void;

    public function match(o: Waveform): Bool;
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

    public function new(a=0.5, f=0.5, p=0.5) {
        amplitude = a;
        frequency = f;
        phase = p;
    }

    public function sample(t:Float):Float {
        var out = 0.5*amplitude*Math.sin( frequency*4*Math.PI*t - phase*Math.PI );
        return out;
    }

    public function draw(target:Graphics, ?phase_delta:Float): Void {
        final drawing_samples = 1000;
        target.lineStyle(0.01, 0x00FF00);
        target.moveTo(0, sample(phase_delta));
        for (i in 0...drawing_samples) {
            var x = i/drawing_samples;
            var y = sample(x + phase_delta);
            y += RNGManager.srand(0.001);
            if (RNGManager.random(10000) == 0) {
                y += RNGManager.srand(0.1);
            }
            y = y < -0.5 ? -0.5: y > 0.5 ? 0.5 : y;
            target.lineTo(x, y);
        }
    }

    public function match(o:Waveform):Bool {
        return defaultMatch(this, o);
    }
}