package gamelogic.physics;

import gamelogic.physics.PhysicalWorld.PHYSICSCALEINVERT;
import box2D.collision.shapes.B2PolygonShape;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2BodyType;
import hxd.earcut.Earcut;
import utilities.Vector2D;

class PolygonalPhysicalGameObject {

    public var body: B2Body;

    public function new(position: Vector2D, polygon: Array<Vector2D>, userdata: Dynamic) {

        var body_definition: B2BodyDef;
        body_definition = new B2BodyDef();
        body_definition.type = B2BodyType.DYNAMIC_BODY;
        body_definition.position = position;
        body_definition.linearDamping = 0.9;
        body_definition.angularDamping = 0.9;
        body_definition.userData = userdata;
        body = PhysicalWorld.gameWorld.createBody(body_definition);
        
        var fixture_definition: B2FixtureDef;
        var e = new Earcut();
        var tris = e.triangulate(polygon);
        var i = 0;
        while (i < tris.length) {
            var tri = B2PolygonShape.asArray([polygon[tris[i]]*PHYSICSCALEINVERT, polygon[tris[i+1]]*PHYSICSCALEINVERT, polygon[tris[i+2]]*PHYSICSCALEINVERT], 3);
            // extra radius to prevent components from sticking so much
            tri.m_radius = 0.05;
            fixture_definition = new B2FixtureDef();
            fixture_definition.shape = tri;
            fixture_definition.friction = 0.5;
            fixture_definition.restitution = 0.5;
            fixture_definition.density = 1;
            fixture_definition.userData = userdata;
            body.createFixture(fixture_definition);
            i += 3;
        }
    }

    public function removePhysics() {
        body.getWorld()?.destroyBody(body);
        body = null;
    }
}