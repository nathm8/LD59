package graphics.shaders;

import h3d.shader.Base2d;

class PeriodicAlphaShader extends hxsl.Shader {

    public function new() {
        super();
        refreshRate = 1.1;
    }

    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var refreshRate : Float;

        function fragment() {
            var x = input.position.x - refreshRate*time;
            x = fract(x);
            
            var p = 0.0;
            if (x < 0.5)
                p = 4*pow(x, 2.0);

            output.color.a *= p;
        }
    }
}