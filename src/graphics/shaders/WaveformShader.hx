package graphics.shaders;

import h3d.Vector;
import h3d.shader.Base2d;

class WaveformShader extends hxsl.Shader {

    public function new() {
        super();
        // speed = 0.24;
        colour = new Vector(1, 0, 0);
        phase = 0;
    }

    static var SRC = {
        @:import h3d.shader.Base2d;

        // doesn't seem to be a way around this magic number >:(
        // AND it can't be Array<Float>, sheesh
        @param var samples : Array<Vec4, 500>;
        // @param var speed : Float;
        @param var colour : Vec3;
        @param var phase : Float;

        function sampleY(x :Float): Float {
            x = fract(x);
            var x1 = int(floor(x * samples.length));
            var x2 = int(ceil( x * samples.length));
            var r = x2 - x1;
            return r*samples[x1].x + (1-r)*samples[x2].x + 0.5;
        }

        // function gauss(x: Float): Float {
        //     var s = 0.1;
        //     var m = 0.5;
        //     var pi = 3.14159;
        //     var mult = 0.25 * 1/(s*sqrt(2*pi));
        //     return mult * exp(-(x-m)*(x-m)/(s*s));
        // }

        function fragment() {
            // zoom in at center so blur isn't cut off by edge
            // var x = 1.3*(input.position.x - 0.5) + 0.5;
            // var y = 1.3*(input.position.y - 0.5) + 0.5;
            var x = input.position.x;
            var y = input.position.y;

            // var wave_y = sampleY(x + speed*time);
            var wave_y = sampleY(x + phase);
            
            var waveform_ratio = 1.0 - distance(vec2(x, y), vec2(x, wave_y));
            waveform_ratio = pow(waveform_ratio, 20);

            if (waveform_ratio > 0)
                output.color += vec4(colour, waveform_ratio);
        }
    }
}