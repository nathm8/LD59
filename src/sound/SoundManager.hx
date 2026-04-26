package sound;

import hxd.snd.Channel;
import hxd.snd.ChannelGroup;
import hxd.snd.SoundGroup;
import gamelogic.Waveform;
import hxd.snd.Manager;
import hxd.res.Sound;
import utilities.MessageManager;

class SoundManager implements MessageListener{
    
    static var soundManager : SoundManager;
    static var manager: Manager;

    static var waveformChannelGroup: ChannelGroup;
    static var waveformSoundGroup: SoundGroup;
    static var playingWaveforms = 0;

    static public function initialise() {
        reset();
    }
    
    static public function reset() {
        manager?.dispose();
        manager = Manager.get();
        waveformChannelGroup = new ChannelGroup("Waveform");
        waveformSoundGroup = new SoundGroup("Waveform");
        if (soundManager == null) soundManager = new SoundManager();
        MessageManager.addListener(soundManager);
    }

    function new(){}

    static public function addWaveform(w: Waveform): CustomSound {
        var sound = new CustomSound(w);
        var channel = manager.play(sound, waveformChannelGroup, waveformSoundGroup);
        playingWaveforms++;
        channel.loop = true;
        // do some dynamic volume EQ so too many sources doesn't get too noisy
        waveformChannelGroup.volume = 0.1 * Math.pow(0.9, playingWaveforms);
        return sound;
    }
    
    public function receive(msg:Message):Bool {
        return false;
    }
}