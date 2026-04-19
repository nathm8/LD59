package gamelogic;

import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import h2d.Object;
import h2d.Bitmap;

class Combinator extends Object implements MessageListener
                                implements Updateable {
    
    var sprite: Bitmap;

    var inputPortOne: Bitmap;
    var inputPortTwo: Bitmap;
    var outputPort: Bitmap;

    public function update(dt:Float):Bool {
        throw new haxe.exceptions.NotImplementedException();
    }

	public function receive(msg:Message):Bool {
		throw new haxe.exceptions.NotImplementedException();
	}
}