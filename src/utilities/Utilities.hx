package utilities;

final colors = [0xFF0000, 0x00FF00, 0x0000FF, 
              0xFFFF00, 0x00FFFF, 0xFFFFFF,
              0xFF00FF];

function clamp(value: Float, low: Float, high: Float): Float {
    if (value < low)
        value = low;
    if (value > high)
        value = high;
    return value;
}

function normaliseArray(arr: Array<Float>): Array<Float> {
    var min = arr[0];
    var max = 0.0;
    for (n in arr) {
        min = n < min ? n : min;
        max = n > max ? n : max;
    }
    max -= min;
    var out = new Array<Float>();
    for (n in arr)
        out.push((n-min)/max);
    return out;
}

function slerp(p: Float, q: Float, r: Float) {
    var u = new Vector2D(1, 0).rotate(p);
    var v = new Vector2D(1, 0).rotate(q);
    return ((1-r)*u + r*v).angle();
}

function normaliseRadian(t: Float, zero_ref = false) {
    if (zero_ref) {
        while (t < -Math.PI)
            t += 2*Math.PI;
        while (t > Math.PI)
            t -= 2*Math.PI;
    } else {
        while (t < 0)
            t += 2*Math.PI;
        while (t > 2*Math.PI)
            t -= 2*Math.PI;
    }
    return t;
}

function toPiMultiple(t: Float) {
    t = normaliseRadian(t);
    return t/Math.PI;
}

function fromPiMultiple(t: Float) {
    t *= Math.PI;
    return normaliseRadian(t);
}

function floatToStringPrecision(n:Float, prec:Int){
    n = Math.round(n * Math.pow(10, prec));
    var str = ''+n;
    var len = str.length;
    if(len <= prec){
        while(len < prec){
            str = '0'+str;
            len++;
        }
        return '0.'+str;
    }
    else{
        return str.substr(0, str.length-prec) + '.'+str.substr(str.length-prec);
    }
}

function prettyPrintVector(v: Vector2D, truncate=false){
    if (truncate)
        return floatToStringPrecision(v.x, 1)+", "+floatToStringPrecision(v.y, 1);
    return "V("+floatToStringPrecision(v.x, 2)+", "+floatToStringPrecision(v.y, 2)+")";
}

function prettyPrintVectorRounded(v: Vector2D, truncate=false){
    if (truncate)
        return Math.round(v.x)+", "+Math.round(v.y);
    return "V("+Math.round(v.x)+", "+Math.round(v.y)+")";
}