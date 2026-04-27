package graphics;

import hxd.Event;
import h2d.Interactive;
import utilities.Vector2D;
import utilities.MessageManager;
import h2d.Object;

final HANDLE_WIDTH = 141;
final HANDLE_HEIGHT = 16;

class Handle extends Object implements MessageListener {
 
    var isSelected = false;
    var selectedOffset = new Vector2D();

    public function new(?p: Object) {
        super(p);

        var i = new Interactive(HANDLE_WIDTH, HANDLE_HEIGHT, this);
        i.onPush = (e:Event) -> {
            isSelected = true;
            
            var event_rel = new Vector2D(e.relX, e.relY);
            i.syncPos();
            var i_abs = new Vector2D(i.absX, i.absY);
            var p_rel = new Vector2D(parent.x, parent.y);
            var i_midpoint = new Vector2D(HANDLE_WIDTH/2, HANDLE_HEIGHT/2);
            
            selectedOffset = p_rel - i_abs - i_midpoint + -(event_rel - i_midpoint);
        }
        i.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function receive(msg: Message): Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            parent.x = params.scenePosition.x + selectedOffset.x;
            parent.y = params.scenePosition.y + selectedOffset.y;
        }
        return false;
    }
}