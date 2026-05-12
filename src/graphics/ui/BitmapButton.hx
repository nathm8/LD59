package graphics.ui;

import h2d.Interactive;
import utilities.MessageManager;
import hxd.res.Loader;
import hxd.Timer;
import h2d.col.PixelsCollider;
import hxd.Event;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;

class BitmapButton extends Bitmap {

    var repeatRate = 0.15;
    var timeRemaining = 0.15;
    var repeating = false;
    public var interactive: Interactive;

    public function new(enabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, onClick:Void -> Void, onLoad:Void -> Void) {
        super(enabled, p);
        interactive = new Interactive(enabled.width, enabled.height, this);

        // button states
        interactive.onClick = (event:Event) -> {
            if (onClick != null)
                onClick();
            tile = active;
            Main.tweenManager.delay(0.1, () -> {tile = loading;}).start();
            Main.tweenManager.delay(0.2, () -> {
                tile = interactive.isOver() ? hover : enabled;
                if (onLoad != null)
                    onLoad();
            }).start();
        };
        interactive.onOver = (e: Event) -> {
            tile = hover;
        };
        interactive.onOut = (e: Event) -> {
            tile = enabled;
            repeating = false;
            timeRemaining = repeatRate;
        };
        // button repeating
        interactive.onRelease = (e: Event) -> {
            repeating = false;
            timeRemaining = repeatRate;
        }
        interactive.onPush = (e: Event) -> {
            repeating = true;
        };
        interactive.onCheck = (e: Event) -> {
            if (!repeating) return;
            timeRemaining -= Timer.dt;
            if (timeRemaining <= 0) {
                timeRemaining = repeatRate;
                // interactive.onClick(e);
            }
        };
    }
}

class ComponentButton extends BitmapButton {
    public function new(button_name: String, p:Object, onClick:Void -> Void, onLoad:Void -> Void) {
        var tiles = new Array<Tile>();
        var loader = Loader.currentInstance;
        for (state in ["Enabled", "Hover", "Active", "Loading"])
            tiles.push( loader.load('img/ui/$button_name$state.png').toTile() );
        super(tiles[0],
              tiles[1],
              tiles[2],
              tiles[3],
              p, onClick, onLoad);
        name = button_name;
    }
}

class MuteButton extends Object {

    var mute: ComponentButton;
    var unmute: ComponentButton;

    public function new(p:Object) {
        super(p);
        mute = new ComponentButton("Mute", this, null, () -> {
                MessageManager.send(new Mute());
                mute.visible = false;
                unmute.visible = true;
            }
            );
        unmute = new ComponentButton("Unmute", this, null, () -> {
            MessageManager.send(new Mute());
            mute.visible = true;
            unmute.visible = false;
        }
        );
        unmute.visible = false;
        scale(0.5);
    }

}