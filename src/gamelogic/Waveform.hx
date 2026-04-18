package gamelogic;

import h2d.Graphics;

interface Waveform {
    // period assumed to be 1.0

    // t in [0,1]
    // return in [0,1]
    public function sample(t: Float): Float;

    public function draw(target: Graphics, ?phase_delta: Float): Void;

}

class Sine implements Waveform {

    var amplitude = 1.0;
    var frequency = 0.5;
    var phase = 0.0;

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
            target.lineTo(x, y);
        }
    }
}