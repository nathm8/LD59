package graphics.ui;

import gamelogic.physics.PhysicalWorld;
import hxd.Window;
import h2d.Scene;
import h2d.Text;
import hxd.Timer;
import utilities.MessageManager;

class UIScene extends Scene implements MessageListener {
    var fpsText: Text;

    public function new() {
        super();
        fpsText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        fpsText.visible = true;
        defaultSmooth = true;
        
        MessageManager.addListener(this);
    }
    
    public function update(dt:Float) {
        fpsText.x = Window.getInstance().width*0.9;
        fpsText.y = Window.getInstance().height*0.9;
        var awake = 0;
        var b = PhysicalWorld.gameWorld.getBodyList();
        while (b != null) {
            if (b.isAwake())
                awake++;
            b = b.getNext();
        }
        fpsText.text = '${Math.round(Timer.fps())}\n${awake}\\${PhysicalWorld.gameWorld.getBodyCount()-1}' ;
    }

    public function receive(msg:Message):Bool {
        return false;
    }

}
