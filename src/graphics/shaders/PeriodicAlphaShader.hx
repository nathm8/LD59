package graphics.shaders;

import h3d.shader.Base2d;

class PeriodicAlphaShader extends hxsl.Shader {

    public function new() {
        super();
        delta = 0;
    }

    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var delta : Float;

        function fragment() {
            var dist = input.position.x - delta;
            var fraction = fract(dist);
            
            var p = 0.0;
            if (fraction < 0.5)
                p = 4*pow(fraction, 2.0);

            output.color.a *= p;
        }
    }
}