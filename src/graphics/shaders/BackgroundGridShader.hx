package graphics.shaders;

import h3d.shader.Base2d;

class BackgroundGridShader extends hxsl.Shader {

    public function new() {
        super();
    }

    static var SRC = {
        @:import h3d.shader.Base2d;

        function grid(st: Vec2, res: Float): Float {
            var grid = fract(st*res);
            return 1.0 - (step(res,grid.x) * step(res,grid.y));
        }
        
        function box(st: Vec2, size: Vec2): Float {
            size = vec2(0.5) - size*0.5;
            var uv = smoothstep(size,
                                size+vec2(0.001),
                                st);
            uv *= smoothstep(size,
                            size+vec2(0.001),
                            vec2(1.0)-st);
            return uv.x*uv.y;
        }

        function fragment() {
            var color = vec3(0.0);
            var grid_st = input.position*101.0;
            color += vec3(0.2,0.,0.)*grid(grid_st,0.02);
            color += vec3(0.2)*grid(grid_st,0.1);

            output.color = vec4(color, 1.0);
        }
    }
}