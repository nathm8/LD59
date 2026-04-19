package graphics.ui;

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

    public function new(enabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, onClick:() -> Void) {
        super(enabled, p);
        var i = new h2d.Interactive(enabled.width, enabled.height, this);

        // button states
        i.onClick = (event:Event) -> {
            onClick(); 
            tile = active;
            Main.tweenManager.delay(0.1, () -> {tile = loading;}).start();
            Main.tweenManager.delay(0.2, () -> {tile = i.isOver() ? hover : enabled;}).start();
        };
        i.onOver = (e: Event) -> {
            tile = hover;
        };
        i.onOut = (e: Event) -> {
            tile = enabled;
            repeating = false;
            timeRemaining = repeatRate;
        };
        // button repeating
        i.onRelease = (e: Event) -> {
            repeating = false;
            timeRemaining = repeatRate;
        }
        i.onPush = (e: Event) -> {
            repeating = true;
        };
        i.onCheck = (e: Event) -> {
            if (!repeating) return;
            timeRemaining -= Timer.dt;
            if (timeRemaining <= 0) {
                timeRemaining = repeatRate;
                i.onClick(e);
            }
        };
    }
}

class ComponentButton extends BitmapButton {
    public function new(button_name: String, p:Object, onClick:() -> Void) {
        var tiles = new Array<Tile>();
        var loader = Loader.currentInstance;
        for (state in ["Enabled", "Hover", "Active", "Loading"])
            tiles.push( loader.load('img/ui/$button_name$state.png').toTile() );
        super(tiles[0],
              tiles[1],
              tiles[2],
              tiles[3],
              p, onClick);
    }
}