package graphics.shaders;

import h3d.shader.Base2d;

class PeriodicAlphaShader extends hxsl.Shader {

    static var SRC = {
        @:import h3d.shader.Base2d;

        function fragment() {
            var x = input.position.x + time;
            while (x > 1)
                x -= 1;
            
            var p = 0.0;
            if (x < 0.5)
                p = 8*pow(x + 0.27, 8.0);
            else
                p = 8*pow(abs(x - 1.27), 8.0);

            output.color.a = p;
        }
    }
}