package;

import UIApp;
import graphics.ui.UIScene;
import gamelogic.CustomSound;
import slide.TweenManager;
import utilities.SoundManager;
import gamelogic.GameScene;
import gamelogic.physics.PhysicalWorld;
import h2d.col.Point;
import utilities.MessageManager;
import utilities.RNGManager;
import hxd.snd.effect.Pitch;

class Main extends UIApp implements MessageListener {

    var gameScene: GameScene;
    var uiScene: UIScene;
    public static var tweenManager: TweenManager;

    static function main() {
        new Main();
    }

    var sdg: SoundDataGenerator;
    var pitch: Pitch;
    var totalTime = 0.0;

    override private function init() {
        // initialise resources
        #if js
        hxd.Res.initEmbed();
        #else
        hxd.Res.initLocal();
        #end
        
        RNGManager.initialise();
        SoundManager.initialise();
        // background
        h3d.Engine.getCurrent().backgroundColor = 0x3A4F41;
        // gamelogic
        newGame();
        // controls
        hxd.Window.getInstance().addEventTarget(onEvent);
    }
    
    override function update(dt:Float) {
        totalTime += dt;
        gameScene?.update(dt);
        uiScene?.update(dt);
        tweenManager?.update(dt);
    }

    function newGame() {
        tweenManager?.stopAll();
        tweenManager = new TweenManager();
        RNGManager.reset();
        MessageManager.reset();
        PhysicalWorld.reset();
        SoundManager.reset();
        uiScene = new UIScene();
        setUI2D(uiScene);
        gameScene = new GameScene();
        setScene2D(gameScene);
        PhysicalWorld.setScene(gameScene);
        MessageManager.addListener(this);
    }

    function onEvent(event:hxd.Event) {
        switch (event.kind) {
            case EPush:
                var p = new Point(event.relX, event.relY);
                s2d.camera.sceneToCamera(p);
                MessageManager.send(new MousePush(event, p));
            case ERelease:
                var p = new Point(event.relX, event.relY);
                s2d.camera.sceneToCamera(p);
                MessageManager.send(new MouseRelease(event, p));
            case EMove:
                var p = new Point(event.relX, event.relY);
                s2d.camera.sceneToCamera(p);
                MessageManager.send(new MouseMove(event, p));
            case EWheel:
                var p = new Point(event.relX, event.relY);
                s2d.camera.sceneToCamera(p);
                MessageManager.send(new MouseWheel(event, p));
            case EKeyDown:
                if (event.keyCode == hxd.Key.ESCAPE)
                    MessageManager.send(new Restart());
            case EKeyUp:
                MessageManager.send(new KeyUp(event.keyCode));
            case _:
        }
    }

    public function receive(msg:Message):Bool {
        // if (Std.isOfType(msg, Restart))
        //     newGame();
        return false;
    }
}