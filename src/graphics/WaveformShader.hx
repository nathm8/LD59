package graphics;

import h3d.shader.Base2d;

class WaveformShader extends hxsl.Shader {

    static var SRC = {
        @:import h3d.shader.Base2d;

        // doesn't seem to be a way around this magic number >:(
        // AND it can't be Array<Float>, sheesh
        @param var samples : Array<Vec4, 500>;
        @param var thickness : Float;

        function plot(y: Float, p: Float): Float{
            return  smoothstep( p-thickness, p, y) -
                    smoothstep( p, p+thickness, y);
        }

        function sampleY(x :Float): Float {
            while (x > 1)
                x -= 1;
            var x1 = int(floor(x * samples.length));
            var x2 = int(ceil( x * samples.length));
            var r = x2 - x1;
            return r*samples[x1].x + (1-r)*samples[x2].x;
        }

        function fragment() {
            var x = input.position.x;
            // imperceptible
            // var x = 1.1*(input.position.x - 0.05);
            var y = 1.1*(input.position.y - 0.05);

            var w = sampleY(x + time);
            var p = plot(y, w);

            output.color = vec4(0.0, 0.0, 0.0, 0.5) + 
                         p*vec4(1.0, 0.0, 0.0, 1.0);
        }
    }
}