package gamelogic.physics;

import box2D.dynamics.B2Fixture;
import box2D.dynamics.B2ContactFilter;

class ContactFilter extends B2ContactFilter {
    override function shouldCollide(fixtureA:B2Fixture, fixtureB:B2Fixture):Bool {
        // custom logic here

        // var user_data_a = fixtureA.getUserData();       
        // var user_data_b = fixtureB.getUserData();
        // if (Std.isOfType(user_data_a, Torpedo) && Std.isOfType(user_data_b, PlayerSub))
        //     return false;
        // if (Std.isOfType(user_data_a, PlayerSub) && Std.isOfType(user_data_b, Torpedo))
        //     return false;

        // default box2d mask logic
        var filter_data_a = fixtureA.getFilterData();
        var filter_data_b = fixtureB.getFilterData();
        if (filter_data_a.groupIndex == filter_data_b.groupIndex && filter_data_a.groupIndex != 0)
            return filter_data_a.groupIndex > 0;
        return ((filter_data_a.maskBits & filter_data_b.categoryBits) != 0) && ((filter_data_a.categoryBits & filter_data_b.maskBits) != 0);
    }
}