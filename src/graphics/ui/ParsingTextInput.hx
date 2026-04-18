package graphics.ui;

import utilities.Vector2D;
import h2d.Object;
import h2d.Font;
import h2d.TextInput;

enum ParsingType {
    Int;
    Float;
    Vector2D;
}

class ParsingTextInput extends TextInput {
    public var value(get, null): Any;
    var type: ParsingType;

    public function new(font:Font, t: ParsingType, ?parent:Object) {
        type = t;
        super(font, parent);
    }

    override function set_text(t:String) {
        if (!isValid(t)) return text;
		super.set_text(t);
		if( cursorIndex > t.length ) cursorIndex = t.length;
		return t;
	}

    function isValid(t: String) : Bool {
        switch(type) {
            case Int:
                return t == "" || Std.parseInt(t) != null;
            case Float:
                return t == "" || Std.parseFloat(t) != Math.NaN;
            case Vector2D:
                var s = t.split(",");
                if (s.length != 2) return false;
                return Std.parseFloat(s[0]) != Math.NaN && Std.parseFloat(s[1]) != Math.NaN;
        }
    }

    public function get_value() : Any {
        // assuming isValid
        switch(type) {
            case Int:
                return cast Std.parseInt(text);
            case Float:
                return cast Std.parseFloat(text);
            case Vector2D:
                var s = text.split(",");
                return cast new Vector2D(Std.parseFloat(s[0]), Std.parseFloat(s[1]));
        }
    }
}
