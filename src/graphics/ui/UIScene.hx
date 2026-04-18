package graphics.ui;

import hxd.Res;
import h2d.Flow;
import gamelogic.physics.PhysicalWorld;
import hxd.Window;
import h2d.Scene;
import h2d.Text;
import hxd.Timer;
import utilities.MessageManager;

class UIScene extends Scene implements MessageListener {
    var fpsText: Text;
    var victoryFlow: Flow;

    public function new() {
        super();
        fpsText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        fpsText.visible = true;
        defaultSmooth = false;
        
        victoryFlow = new Flow(this);
        victoryFlow.backgroundTile = Res.img.ui.ScaleGrid.toTile();
        victoryFlow.borderWidth = 5;
        victoryFlow.borderHeight = 13;
        victoryFlow.padding = 200;
        victoryFlow.alpha = 0.0;
        var victoryText = new h2d.Text(hxd.res.DefaultFont.get(), victoryFlow);
        victoryText.text = "a winner is u~";
        victoryFlow.x = width/2 - victoryFlow.outerWidth/2;
        victoryFlow.y = height/2 - victoryFlow.outerHeight/2;

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
        // fpsText.text = '${Math.round(Timer.fps())}\n${awake}\\${PhysicalWorld.gameWorld.getBodyCount()-1}' ;
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, Victory)) {
            Main.tweenManager.animateTo(victoryFlow, {alpha: 1}, 1.0).start();
        }
        return false;
    }

}
