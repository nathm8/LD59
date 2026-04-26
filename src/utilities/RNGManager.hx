package utilities;

import hxd.Rand;

class RNGManager {
    static var init = false;
    public static var seed(get, null): Int;
    static var rand: Rand;
    
    public static function initialise(s=-1) {
        if (init) return;
        init = true;
        if (s == -1)
            seed = Std.random(0x7FFFFFFF);
        else
            seed = Std.random(s);
        rand = new Rand(seed);
    }

    public static function reset() {
        init = false;
        initialise();
    }

    public static function get_seed(): Int {
        if (!init) initialise();
        return seed;
    }

	public static inline function random( n ): Int {
        if (!init) initialise();
		return rand.random(n);
	}

    public static inline function randoms( n, k, distinct=false ): Array<Int> {
        if (!init) initialise();
        if (k > n) {
            distinct = false;
            trace('unable to take $k distinct samples from [0, $n), setting distinct = false');
        } 
        var out = new Array<Int>();
        while (out.length < k) {
            var x = random(n);
            if (distinct && out.contains(x))
                continue;
            out.push(x);
        }
		return out;
	}

	public static inline function shuffle<T>( a : Array<T> ) {
        if (!init) initialise();
		return rand.shuffle(a);
	}

	public static inline function srand(scale=1.0, positive=false) {
        if (!init) initialise();
        if (positive) {
            return scale/2 + rand.srand(scale/2);
        }
		return rand.srand(scale);
	}

    public static inline function randomAngle(): Float {
        if (!init) initialise();
        return rand.rand() * 2 * Math.PI;
    }

    // maybe just make a big list of this and pick a random one
    public static inline function normal(mu:Float=0, sigma:Float=1): Float {
        if (!init) initialise();
        function marsaglia() : Float {
            var x = 0.0;
            while (true) {
                var i = rand.srand();
                var j = rand.srand();
                x = i*i + j*j;
                if (x < 1) break;
            }
            return Math.sqrt(-2 * Math.log(x) / x);
        }
        return mu + sigma*marsaglia();
    }

}