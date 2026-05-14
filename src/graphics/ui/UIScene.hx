package graphics.ui;

import graphics.ui.BitmapButton.MuteButton;
import h2d.Object;
import h2d.Bitmap;
import graphics.ui.BitmapButton.ComponentButton;
import hxd.Res;
import h2d.Flow;
import h2d.Scene;
import h2d.Text;
import hxd.Timer;
import utilities.MessageManager;

class UIScene extends Scene implements MessageListener {
    var fpsText: Text;
    var victoryFlow: Flow;
    var componentFlow: Flow;
    
    var tutorialText: Text;

    var statsText: Text;
    var totalTime = 0.0;
    var solvedPuzzles = 0;

    var tutorialState = 0;
    var sineSpawned = false;
    var cableSpawned = false;

    var sineConnected = false;
    var outputConnected = false;

    public function new() {
        super();
        fpsText = new h2d.Text(hxd.res.DefaultFont.get(), this);

        statsText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        statsText.visible = false;
        statsText.x = width*0.9;
        statsText.y = height*0.9;
        
        victoryFlow = new Flow(this);
        victoryFlow.backgroundTile = Res.img.ui.ScaleGrid.toTile();
        victoryFlow.borderWidth = 5;
        victoryFlow.borderHeight = 13;
        victoryFlow.padding = 200;
        victoryFlow.alpha = 0.0;
        var victoryText = new h2d.Text(hxd.res.DefaultFont.get(), victoryFlow);
        victoryText.text = '~a winner is u~';
        victoryText.scale(5);
        victoryFlow.x = width/2 - victoryFlow.outerWidth/2;
        victoryFlow.y = height/2 - victoryFlow.outerHeight/2;

        componentFlow = new Flow(this);
        componentFlow.backgroundTile = Res.img.ui.ScaleGrid.toTile();
        componentFlow.borderWidth = 5;
        componentFlow.borderHeight = 20;
        componentFlow.horizontalSpacing = 10;
        componentFlow.padding = 20; 

        var hidden = ["Split", "Square", "Triangle", "And", "Or", "Invert", "UIBreak1", "UIBreak2", "UIBreak3", "Phase"];
        var num = 0;
        for (name in ["Wire", "Split", "UIBreak", "Sine", "Square", "Triangle", "UIBreak", "Phase", "And", "Or", "Invert", "UIBreak", "Bin"]) {
            var b: Object;
            if (name == "UIBreak") {
                b = new Bitmap(Res.img.ui.UIBreak.toTile(), componentFlow);
                b.name = 'UIBreak$num';
                // b.visible = num == 0;
                num++;
            } else {
                b = new ComponentButton(name, componentFlow, () -> MessageManager.send(new SpawnComponent(name)), null);
            }
            // if (hidden.contains(name))
            //     b.visible = false;
        }
        componentFlow.x = width/2 - componentFlow.outerWidth/2;
        componentFlow.y = height - componentFlow.outerHeight;

        var muteButton = new MuteButton(this);
        muteButton.x = width - 80;
        muteButton.y = 10;

        tutorialText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        tutorialText.textAlign = Center;
        tutorialText.text = "Spawn in a Sine generator and a cable";
        tutorialText.scale(3);
        tutorialText.x = width/2;
        tutorialText.y = componentFlow.y - 100;
        tutorialText.alpha = 0;
        Main.tweenManager.animateTo(tutorialText, {alpha: 1}, 1.0).start();

        MessageManager.addListener(this);
    }
    
    public function update(dt:Float) {
        totalTime += dt;
        // fpsText.text = '${Math.round(Timer.fps())}\n${awake}\\${PhysicalWorld.gameWorld.getBodyCount()-1}' ;
        fpsText.text = '${Math.round(Timer.fps())}';
        statsText.text = 'time:${Math.round(totalTime)}\nsolved: ${solvedPuzzles}';
    }

    function tutorialCheck() {
        if (tutorialState == 0 && cableSpawned && sineSpawned) {
            tutorialState++;
            tutorialText.alpha = 0;
            tutorialText.text = "Drag components by clicking and holding their red parts\nConnect the generator to the ¿Dëvicé?";
            tutorialText.x = width/2;
            Main.tweenManager.animateTo(tutorialText, {alpha: 1}, 2.0).start();
        }
        if (tutorialState == 1 && sineConnected && outputConnected) {
            tutorialState++;
            tutorialText.alpha = 0;
            tutorialText.text = "Match the signal, and then flip the switch";
            tutorialText.x = width/2;
            Main.tweenManager.animateTo(tutorialText, {alpha: 1}, 2.0).start();
        }
        if (tutorialState == 2 && solvedPuzzles == 1) {
            tutorialState++;
            tutorialText.alpha = 0;
            tutorialText.text = "If you need more room:\nYou can zoom in and out with the mouse wheel, or Q and E.\nDragging the middle mouse button or WASD can pan the camera.";
            tutorialText.x = width/2;
            tutorialText.y -= 50;
            for (n in ["Or", "Square", "UIBreak1"])
                componentFlow.getObjectByName(n).visible = true;
            componentFlow.x = width/2 - componentFlow.outerWidth/2;
            Main.tweenManager.animateTo(tutorialText, {alpha: 1}, 2.0).start();
            Main.tweenManager.delay(5, () -> {
                Main.tweenManager.animateTo(tutorialText, {alpha: 0}, 2.0).start();
            }).start();
        }
        if (tutorialState == 3 && solvedPuzzles == 2) {
            tutorialState++;
            tutorialText.text = "These are all the tools. There are six puzzles.\nGood luck!";
            tutorialText.x = width/2;
            tutorialText.y -= 50;
            for (c in componentFlow.children)
                c.visible = true;
            componentFlow.x = width/2 - componentFlow.outerWidth/2;
            Main.tweenManager.animateTo(tutorialText, {alpha: 1}, 2.0).start();
            Main.tweenManager.delay(5, () -> {
                Main.tweenManager.animateTo(tutorialText, {alpha: 0}, 2.0).start();
            }).start();
            statsText.visible = true;
        }
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, SpawnComponent)) {
            var params = cast(msg, SpawnComponent);
            if (params.componentName == "Wire")
                cableSpawned = true;
            if (params.componentName == "Sine")
                sineSpawned = true;
            tutorialCheck();
        }
        if (Std.isOfType(msg, OutputConnected)) {
            outputConnected = true;
            tutorialCheck();
        }
        if (Std.isOfType(msg, SineConnected)) {
            sineConnected = true;
            tutorialCheck();
        }
        if (Std.isOfType(msg, Victory)) {
            solvedPuzzles++;
            tutorialCheck();
            if (solvedPuzzles == 6)
                Main.tweenManager.animateTo(victoryFlow, {alpha: 1}, 1.0).start();
        }
        return false;
    }

}
