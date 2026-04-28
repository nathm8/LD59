package gamelogic;

import utilities.Assert.assert;
import h2d.col.Circle;
import utilities.MessageManager;
import utilities.MessageManager.MouseMove;
import utilities.Utilities.normaliseRadian;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import utilities.Vector2D;
import hxd.Event;
import h2d.Interactive;
import h2d.Object;
import h2d.Bitmap;
import hxd.Res;

class Dial extends Object implements MessageListener implements Updateable {
    // between 1 and 8
    public var value = 8;

    var sprite: Bitmap;
    var interactive: Interactive;
    var isSelected = false;
    var moveImmune = 0.25;
    var selectedTime = 0.0;
    var callback: Void -> Void;

    public function new(v: Int, f: Void -> Void, p: Object) {
        super(p);
        value = v;
        callback = f;
        var t = Res.img.Dial.toTile();
        t.setCenterRatio(0.5, 0.83);
        sprite = new Bitmap(t, this);
        rotation = value*2*Math.PI/8;

        interactive = new Interactive(t.width, t.height, this, new Circle(0, 0, 40));
        interactive.enableRightButton = true;
        interactive.onRelease = (e:Event) -> {
            isSelected = false;
        }
        interactive.onPush = (e:Event) -> {
            selectedTime = 0;
            isSelected = true;
            moveImmune = 0.25;
        }
        interactive.onClick = (e:Event) -> {
            if (selectedTime < 0.1) {
                if (e.button == 0)
                    value++;
                else
                    value--;
            }
            value = value == 0 ? 8 : value == 9 ? 1 : value;
            rotation = value*2*Math.PI/8;
            callback();
        };

        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            if (moveImmune > 0) return false;
            var params = cast(msg, MouseMove);
            var v = new Vector2D(x, y);
            var p = sprite.getAbsPos().getPosition();
            var u = new Vector2D(p.x, p.y);
            var r = normaliseRadian((params.scenePosition - u).angle() + 1.5*Math.PI/8);
            value = Math.round(r/(Math.PI/4)) + 1;
            value = value == 9 ? 1 : value;
            rotation = value*2*Math.PI/8;
            callback();
        }
        return false;
    }

    public function update(dt:Float):Bool {
        if (moveImmune > 0 && isSelected) moveImmune -= dt;
        if (isSelected) selectedTime += dt;
        return false;
    }
}