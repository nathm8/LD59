package gamelogic.physics;

import box2D.dynamics.B2ContactImpulse;
import box2D.dynamics.contacts.B2Contact;
import box2D.dynamics.B2ContactListener;

class ContactListener extends B2ContactListener {
    override public function postSolve(contact:B2Contact, impulse:B2ContactImpulse):Void {
        var object_a = contact.getFixtureA().getUserData();
        var object_b = contact.getFixtureB().getUserData();
        // if (Std.isOfType(object_a, Bullet))
        //     MessageManager.send(new BulletHit(cast(object_a, Torpedo)));
        // if (Std.isOfType(object_b, Torpedo))
        //     MessageManager.sendMessage(new TorpedoHitMessage(cast(object_b, Torpedo)));
    }
}