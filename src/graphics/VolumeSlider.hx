package graphics;

import hxd.snd.Channel;
import slide.Tween;
import utilities.Utilities.clamp;
import utilities.Vector2D;
import h2d.col.Circle;
import hxd.Event;
import hxd.Res;
import h2d.Interactive;
import h2d.Bitmap;
import h2d.Object;
import utilities.MessageManager;

class VolumeSlider extends Object implements MessageListener {
    // 206 total width
    // 13 cap
    public var startPos = new Vector2D(-87, 0);
    public var endPos = new Vector2D(87, 0);
    
    var tween: Tween;
    
    var slider: Bitmap;
    var channel: Channel;
    
    var savedVolume: Float;
    var isSelected = false;
    
    public function new(c: Channel, ?p: Object) {
        super(p);
        
        channel = c;
        channel.volume = 0.5;
        savedVolume = channel.volume;

        slider = new Bitmap(Res.img.Slider.toTile().center(), this);
        // slider.x = startPos.x;
        
        var i = new Interactive(0, 0, slider, new Circle(0, 0, 22));
        i.onPush = (e: Event) -> {
            isSelected = true;
        };
        i.onRelease = (e: Event) -> {
            isSelected = false;
        };

        MessageManager.addListener(this);
    }

    public function receive(msg: Message): Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            var start_abs = localToGlobal(startPos);
            var end_abs = localToGlobal(endPos);
            
            var mouse_x = params.scenePosition.x;
            var x_diff = mouse_x - start_abs.x;

            var r = 1 - x_diff/(end_abs.x - start_abs.x);
            r = clamp(r, 0, 1);

            channel.volume = 1 - r;
            savedVolume = channel.volume;

            slider.x = r*startPos.x + (1-r)*endPos.x;
        }
        return false;
    }

    public function mute() {
        tween?.stop();
        savedVolume = channel.volume;
        tween = Main.tweenManager.animateTo(channel, { volume: 0}, 0.5).onUpdate(
            () -> {slider.x = (1 - channel.volume)*startPos.x + channel.volume*endPos.x;}
        );
        tween.start();
    }

    public function restore() {
        tween?.stop();
        tween = Main.tweenManager.animateTo(channel, { volume: savedVolume}, 0.5).onUpdate(
            () -> {slider.x = (1 - channel.volume)*startPos.x + channel.volume*endPos.x;}
        );
        tween.start();
    }
}