package sound;

import gamelogic.Waveform;
import hxd.fs.BytesFileSystem.BytesFileEntry;
import hxd.snd.Data;
import hxd.res.Sound;

import hxd.snd.Data.SampleFormat;
import haxe.io.Bytes;

// from https://gist.github.com/Eiyeron/0f3d49082308389e9a17d1e650f3453d
class SoundDataGenerator extends hxd.snd.Data
{
    private var waveform: Waveform;
    public var reload: Void -> Void;

    public function new(w: Waveform) {
        samplingRate = 3000;
        sampleFormat = SampleFormat.UI8;
        samples = samplingRate;
        channels = 1;
        
        waveform = w;
    }

    // called from hxd.snd.Data.decode
    public override function decodeBuffer(out:Bytes, outPos:Int, sampleStart:Int, sampleCount:Int) {
        for (i in outPos...out.length) {
            var r = i/out.length;
            // todo, random up this multiplier
            var v = Math.round(50000*waveform.sample(r, 0, true));
            out.set(i, v);
        }
    }

    // need to force hxd.snd.Manager.fillSoundBuffer recall when waveform changes
    override public function load( onEnd : Void -> Void ) {
        reload = onEnd;
		onEnd();
	}
}

// from https://gist.github.com/Eiyeron/0f3d49082308389e9a17d1e650f3453d
class CustomSound extends Sound {

    static var id = 0;

    public function new(w: Waveform) {
        super(null);
        id++;
        data = new SoundDataGenerator(w);
        // dummy, path is used in hxd.snd.Manager as a hashmap key
        entry = new BytesFileEntry('CustomSound${id}', Bytes.alloc(0));
    }

    public override function toString():String {
        return "Waveform sound generator";
    }

    public function reload() {
        var d = cast(data, SoundDataGenerator);
        d.reload();
    }
}