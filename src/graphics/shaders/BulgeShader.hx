package graphics.shaders;

import h3d.shader.ScreenShader;
import h3d.shader.Base2d;

// UwU
class BulgeShader extends ScreenShader {

    
    static var SRC = {
        @param var texture : Sampler2D;

        function curve(uv:Vec2) : Vec2 {
			var out = uv*2 - 1;
            var curvature = vec2(1.5, 2.0);

			var offset = abs(out.yx) / curvature;
			out = out + out * offset * offset;

			out = out*0.5 + 0.5;
			return out;
		}

        function fragment() {
            var uv = curve( input.uv );
            pixelColor = texture.get(uv);
        }
    }
}