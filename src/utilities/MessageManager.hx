package utilities;

import hxd.fs.FileEntry;
import hxd.Event;
import utilities.Vector2D;

class Message {public function new(){}}

class Victory extends Message {}
class Restart extends Message {}
class MousePush extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}
class KeyUp extends Message {
    public var keycode: Int;
    public function new(k: Int) {super(); keycode = k;}
}
class MouseRelease extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}
class MouseMove extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}
class MouseWheel extends Message {
    public var event: Event;
    public var scenePosition: Vector2D;
    public function new(e: Event, p: Vector2D) {super(); event = e; scenePosition = p;}
}

interface MessageListener {
    public function receive(msg: Message): Bool;
}

class MessageManager {

    static var listeners = new Array<MessageListener>();

    public static function addListener(l:MessageListener) {
        listeners.push(l);
    }

    public static function removeListener(l:MessageListener) {
        listeners.remove(l);
    }

    public static function send(msg: Message) {
        for (l in listeners)
            if (l.receive(msg)) return;
        // trace("unconsumed message", msg);
    }

    public static function reset() {
        listeners = [];
    }

}