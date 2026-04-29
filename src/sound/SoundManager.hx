package sound;

import hxd.snd.Channel;
import hxd.snd.ChannelGroup;
import hxd.snd.SoundGroup;
import gamelogic.Waveform;
import hxd.snd.Manager;
import utilities.MessageManager;

class SoundManager implements MessageListener{
    
    static var soundManager : SoundManager;
    static var manager: Manager;

    static var waveformChannelGroup: ChannelGroup;
    static var waveformSoundGroup: SoundGroup;
    static var waveformChannels: Array<Channel>;

    static public function initialise() {
        reset();
    }
    
    static public function reset() {
        manager?.dispose();
        manager = Manager.get();
        waveformChannels = new Array<Channel>();
        waveformChannelGroup = new ChannelGroup("Waveform");
        waveformSoundGroup = new SoundGroup("Waveform");
        if (soundManager == null) soundManager = new SoundManager();
        MessageManager.addListener(soundManager);
    }

    function new(){}

    static public function addWaveform(w: Waveform): {sound: CustomSound, channel: Channel} {
        var sound = new CustomSound(w);
        var channel = manager.play(sound, waveformChannelGroup, waveformSoundGroup);
        channel.loop = true;
        waveformChannels.push(channel);
        dynamicEQ();
        return {sound: sound, channel: channel};
    }
    
    static function dynamicEQ() {
        var playing_waveforms = 0;
        for (c in waveformChannels)
            if (c.volume > 0)
                playing_waveforms++;
        // do some dynamic volume EQ so too many sources doesn't get too noisy
        waveformChannelGroup.volume = 0.1 * Math.pow(0.9, Math.min(playing_waveforms, Manager.MAX_SOURCES));
    }
    
    public function receive(msg:Message):Bool {
        return false;
    }
}