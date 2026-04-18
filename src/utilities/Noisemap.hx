package utilities;

import hxd.Perlin;

class Noisemap {
    static var noise = new Perlin();
    // static var noise2 = new Perlin();
    static var seed = RNGManager.random(0xFFFFFF);
    static var initialised = false;

    static function init() {
        noise.normalize = true;
        // noise2.normalize = true;
        initialised = true;
    }
    
    static public function getNoiseAtTheta(theta: Float) : Float {
        if (!initialised) init();
        var n = 0.0;
        for (s in [1, 2, 3]) {
            var x = Math.cos(theta)/s + 1;
            var y = Math.sin(theta)/s + 1;
            n += s*noise.perlin(seed, x, y, s, 5, 2.2);
        }
        return n;
    }

}