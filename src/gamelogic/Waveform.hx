package gamelogic;

interface Waveform {
    // period assumed to be 1.0

    // t in [0,1]
    // return in [0,1]
    public function sample(t: Float): Float;

}

class Sine implements Waveform {

    var amplitude = 0.25;
    var frequency = 0.5;
    var phase = 0.0;

    public function new() {}

    public function sample(t:Float):Float {
        var out = 0.5*amplitude*Math.sin( frequency*4*Math.PI*t - phase*Math.PI ) + 0.5*amplitude;
        return out;
    }
}