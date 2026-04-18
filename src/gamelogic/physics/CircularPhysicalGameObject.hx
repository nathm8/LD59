package gamelogic.physics;

import box2D.collision.shapes.B2CircleShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import utilities.Vector2D;

class CircularPhysicalGameObject {

    public var body: B2Body;

    public function new(position: Vector2D, radius: Float, userdata: Dynamic, bd: B2BodyDef=null, fd: B2FixtureDef=null) {

        var body_definition: B2BodyDef;
        if (bd != null)
            body_definition = bd
        else {
            body_definition = new B2BodyDef();
            body_definition.type = B2BodyType.DYNAMIC_BODY;
            body_definition.position = position;
            body_definition.linearDamping = 0.1;
            body_definition.fixedRotation = true;
        }
        body = PhysicalWorld.gameWorld.createBody(body_definition);
        
        var fixture_definition: B2FixtureDef;
        if (fd != null)
            fixture_definition = fd;
        else {
            var circle = new B2CircleShape();
            circle.setRadius(radius);
            fixture_definition = new B2FixtureDef();
            fixture_definition.shape = circle;
            fixture_definition.friction = 0.5;
            fixture_definition.restitution = 0.5;
            fixture_definition.density = 1;
            fixture_definition.userData = userdata;
        }

        body.createFixture(fixture_definition);
    }

    public function removePhysics() {
        body.getWorld()?.destroyBody(body);
        body = null;
    }
}