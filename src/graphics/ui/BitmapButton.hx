package graphics.ui;

import hxd.Timer;
import h2d.col.PixelsCollider;
import hxd.Event;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;

class BitmapButton extends Bitmap {

    static var initialised = false;
    static var pixelsCollider: PixelsCollider;
    
    var repeatRate = 0.15;
    var timeRemaining = 0.15;
    var repeating = false;

    public function new(enabled:Tile, disabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, onClick:() -> Void) {
        super(enabled, p);
        if (!initialised) {
            initialised = true;
            pixelsCollider = new PixelsCollider(enabled.getTexture().capturePixels());
        }
        var i = new h2d.Interactive(enabled.width, enabled.height, this, pixelsCollider);

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

enum ButtonDirection {
    Up;
    Down;
    Left;
    Right;
}

class TriangleButton extends BitmapButton {
    public function new(p:Object, onClick:() -> Void, dirc: ButtonDirection) {
        var enabled, disabled, hover, active, loading : Tile;
        switch (dirc) {
            case Up:
                enabled = hxd.Res.img.ui.TriangleButton.UpEnabled.toTile();
                disabled = hxd.Res.img.ui.TriangleButton.UpDisabled.toTile();
                hover = hxd.Res.img.ui.TriangleButton.UpHover.toTile();
                active = hxd.Res.img.ui.TriangleButton.UpActive.toTile();
                loading = hxd.Res.img.ui.TriangleButton.UpLoading.toTile();
            case Down:
                enabled = hxd.Res.img.ui.TriangleButton.DownEnabled.toTile();
                disabled = hxd.Res.img.ui.TriangleButton.DownDisabled.toTile();
                hover = hxd.Res.img.ui.TriangleButton.DownHover.toTile();
                active = hxd.Res.img.ui.TriangleButton.DownActive.toTile();
                loading = hxd.Res.img.ui.TriangleButton.DownLoading.toTile();
            case Left:
                enabled = hxd.Res.img.ui.TriangleButton.LeftEnabled.toTile();
                disabled = hxd.Res.img.ui.TriangleButton.LeftDisabled.toTile();
                hover = hxd.Res.img.ui.TriangleButton.LeftHover.toTile();
                active = hxd.Res.img.ui.TriangleButton.LeftActive.toTile();
                loading = hxd.Res.img.ui.TriangleButton.LeftLoading.toTile();
            case Right:
                enabled = hxd.Res.img.ui.TriangleButton.RightEnabled.toTile();
                disabled = hxd.Res.img.ui.TriangleButton.RightDisabled.toTile();
                hover = hxd.Res.img.ui.TriangleButton.RightHover.toTile();
                active = hxd.Res.img.ui.TriangleButton.RightActive.toTile();
                loading = hxd.Res.img.ui.TriangleButton.RightLoading.toTile();
        }
        super(enabled,
              disabled,
              hover,
              active,
              loading,
              p, onClick);
    }
}

class RotationButton extends BitmapButton {
    public function new(p:Object, onClick:() -> Void, x_flip=false) {
        var enabled, disabled, hover, active, loading : Tile;
        if (x_flip) {
            enabled = hxd.Res.img.ui.RotationButton.XMirrorEnabled.toTile();
            disabled = hxd.Res.img.ui.RotationButton.XMirrorDisabled.toTile();
            hover = hxd.Res.img.ui.RotationButton.XMirrorHover.toTile();
            active = hxd.Res.img.ui.RotationButton.XMirrorActive.toTile();
            loading = hxd.Res.img.ui.RotationButton.XMirrorLoading.toTile();
        }
        else {
            enabled = hxd.Res.img.ui.RotationButton.Enabled.toTile();
            disabled = hxd.Res.img.ui.RotationButton.Disabled.toTile();
            hover = hxd.Res.img.ui.RotationButton.Hover.toTile();
            active = hxd.Res.img.ui.RotationButton.Active.toTile();
            loading = hxd.Res.img.ui.RotationButton.Loading.toTile();
        }

        super(enabled,
              disabled,
              hover,
              active,
              loading,
              p, onClick);
    }
}

class ReticleButton extends BitmapButton {
    public function new(p:Object, onClick:() -> Void) {
        var enabled, disabled, hover, active, loading : Tile;
        enabled = hxd.Res.img.ui.ReticleButton.Enabled.toTile();
        disabled = hxd.Res.img.ui.ReticleButton.Disabled.toTile();
        hover = hxd.Res.img.ui.ReticleButton.Hover.toTile();
        active = hxd.Res.img.ui.ReticleButton.Active.toTile();
        loading = hxd.Res.img.ui.ReticleButton.Loading.toTile();
        super(enabled,
              disabled,
              hover,
              active,
              loading,
              p, onClick);
    }
}