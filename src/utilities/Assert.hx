package utilities;

import haxe.macro.Expr;
import haxe.macro.ExprTools;

// https://gist.github.com/bendmorris/7695f36dbc8c2968c2a5d6bdde5f0592
macro function assert( e: ExprOf<Bool> )
{
    var assertion = ExprTools.toString(e);
    return macro 
    {
        if (!$e) 
        {
            trace("Assertion failed: " + $v{assertion});
            throw "Assertion failed: " + $v{assertion};
        }
    };
}