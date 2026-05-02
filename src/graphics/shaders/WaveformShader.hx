package graphics.shaders;

import h3d.Vector;
import h3d.shader.Base2d;

class WaveformShader extends hxsl.Shader {

    public function new() {
        super();
        speed = 0.24;
        thickness = 0.01;
        colour = new Vector(1, 0, 0);
    }

    static var SRC = {
        @:import h3d.shader.Base2d;

        // doesn't seem to be a way around this magic number >:(
        // AND it can't be Array<Float>, sheesh
        @param var samples : Array<Vec4, 500>;
        @param var thickness : Float;
        @param var speed : Float;
        @param var colour : Vec3;

        function plot(y: Float, p: Float): Float{
            return  smoothstep( p-thickness, p, y) -
                    smoothstep( p, p+thickness, y);
        }

        function sampleY(x :Float): Float {
            x = fract(x);
            var x1 = int(floor(x * samples.length));
            var x2 = int(ceil( x * samples.length));
            var r = x2 - x1;
            return r*samples[x1].x + (1-r)*samples[x2].x;
        }

        function fragment() {
            // draw waveform
            var x = input.position.x;
            var y = 1.1*(input.position.y - 0.05);

            var w = sampleY(x + speed*time);
            var waveform_ratio = plot(y, w);
            waveform_ratio = max(waveform_ratio - 0.1, 0);

            if (waveform_ratio > 0)
                output.color += vec4(colour, waveform_ratio);
        }
    }
}