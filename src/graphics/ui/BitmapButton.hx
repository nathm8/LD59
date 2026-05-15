package graphics.ui;

import gamelogic.Updateable;
import hxd.res.DefaultFont;
import hxd.Res;
import h2d.Flow;
import h2d.Text;
import utilities.MessageManager;
import hxd.res.Loader;
import hxd.Timer;
import hxd.Event;
import h2d.Interactive;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;

class BitmapButton extends Bitmap implements Updateable {

    var repeatRate = 0.15;
    var timeRemaining = 0.15;
    final tooltipCountdownMax = 0.5;
    var tooltipCountdown = 0.5;
    var repeating = false;
    var isHovered = false;
    public var interactive: Interactive;
    var tooltip: Flow;

    public function new(enabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, tt: String, onClick: Void -> Void, onLoad: Void -> Void) {
        super(enabled, p);
        interactive = new Interactive(enabled.width, enabled.height, this);

        tooltip = new Flow(this);
        tooltip.backgroundTile = Res.img.ui.ScaleGridBlack.toTile();
        tooltip.borderWidth = 8;
        tooltip.borderHeight = 8;
        tooltip.padding = 5;
        tooltip.visible = false;

        var text = new Text(DefaultFont.get(), tooltip);
        text.smooth = false;
        text.text = tt;
        text.textAlign = MultilineCenter;

        var size = getSize();
        tooltip.x = Math.round(size.width/2 - tooltip.outerWidth/2);
        tooltip.y = Math.round(size.height/2 - tooltip.outerHeight/2);

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
            isHovered = true;
        };
        interactive.onOut = (e: Event) -> {
            tile = enabled;
            repeating = false;
            timeRemaining = repeatRate;
            tooltip.visible = false;
            isHovered = false;
            tooltipCountdown = tooltipCountdownMax;
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

    public function update(dt:Float):Bool {
        if (isHovered) {
            tooltipCountdown -= dt;
            if (tooltipCountdown <= 0)
                tooltip.visible = true;
        }
        return false;
    }
}

class ComponentButton extends BitmapButton {
    public function new(button_name: String, p:Object, tt: String, onClick:Void -> Void, onLoad:Void -> Void) {
        var tiles = new Array<Tile>();
        var loader = Loader.currentInstance;
        for (state in ["Enabled", "Hover", "Active", "Loading"])
            tiles.push( loader.load('img/ui/$button_name$state.png').toTile() );
        super(tiles[0],
              tiles[1],
              tiles[2],
              tiles[3],
              p, tt, onClick, onLoad);
        name = button_name;
    }
}

class TrashButton extends ComponentButton {
    public function new(button_name: String, p:Object, onClick:Void -> Void, onLoad:Void -> Void) {
        super(button_name, p, "delete components", onClick, onLoad);
    }
}

class MuteButton extends Object implements Updateable  {

    var mute: ComponentButton;
    var unmute: ComponentButton;

    public function new(p:Object) {
        super(p);
        mute = new ComponentButton("Mute", this, "Mute all sound", null, () -> {
                MessageManager.send(new Mute());
                mute.visible = false;
                unmute.visible = true;
            }
        );
        unmute = new ComponentButton("Unmute", this, "Unmute all sound", null, () -> {
                MessageManager.send(new Mute());
                mute.visible = true;
                unmute.visible = false;
            }
        );
        unmute.visible = false;
    }


    public function update(dt:Float):Bool {
        mute.update(dt);
        unmute.update(dt);
        return false;
    }
}