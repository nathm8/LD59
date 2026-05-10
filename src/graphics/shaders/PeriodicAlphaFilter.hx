package graphics.shaders;

import h3d.shader.ScreenShader;

class PeriodicAlphaFilter extends ScreenShader {

    public function new() {
        super();
        delta = 0;
    }

    static var SRC = {
        @param var texture : Sampler2D;
        @global var time:Float;
        @param var delta : Float;

        function fragment() {
            var dist = input.uv.x - delta;
            var fraction = fract(dist);
            
            var p = 0.0;
            if (fraction < 0.5)
                p = 4*pow(fraction, 2.0);
            
            pixelColor = texture.get(input.uv);
            pixelColor.rgb *= p;
            pixelColor.a = 0;
        }
    }
}