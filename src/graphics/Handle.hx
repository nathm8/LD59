package graphics;

import box2D.dynamics.B2Body;
import gamelogic.physics.PhysicalWorld;
import box2D.dynamics.joints.B2MouseJointDef;
import box2D.dynamics.joints.B2MouseJoint;
import hxd.Event;
import h2d.Interactive;
import utilities.Vector2D;
import utilities.MessageManager;
import h2d.Object;

final HANDLE_WIDTH = 141;
final HANDLE_HEIGHT = 16;

class Handle extends Object implements MessageListener {
 
    var isSelected = false;
    var selectedOffset = new Vector2D();
    var interactive: Interactive;

    public function new(?p: Object) {
        super(p);

        interactive = new Interactive(HANDLE_WIDTH, HANDLE_HEIGHT, this);
        interactive.onPush = (e:Event) -> {
            isSelected = true;
            
            var event_rel = new Vector2D(e.relX, e.relY);
            interactive.syncPos();
            var i_abs = new Vector2D(interactive.absX, interactive.absY);
            var p_rel = new Vector2D(parent.x, parent.y);
            var i_midpoint = new Vector2D(HANDLE_WIDTH/2, HANDLE_HEIGHT/2);
            
            selectedOffset = p_rel - i_abs - i_midpoint + -(event_rel - i_midpoint);
        }
        interactive.onRelease = (e:Event) -> {isSelected = false;}

        MessageManager.addListener(this);
    }

    public function receive(msg: Message): Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            parent.x = params.scenePosition.x + selectedOffset.x;
            parent.y = params.scenePosition.y + selectedOffset.y;
        }
        return false;
    }
}

class PhysicalHandle extends Handle {
 
    var mouseJoint: B2MouseJoint;

    public function new(body: B2Body, ?p: Object) {
        super(p);

        interactive.onRelease = (e:Event) -> {
            isSelected = false;
            mouseJoint.setMaxForce(0);
        }

        var mouse_joint_definition = new B2MouseJointDef();
        mouse_joint_definition.bodyA = PhysicalWorld.gameWorld.m_groundBody;
        mouse_joint_definition.bodyB = body;
        mouse_joint_definition.collideConnected = false;
        mouse_joint_definition.dampingRatio = 0.95;
        
        mouseJoint = cast(PhysicalWorld.gameWorld.createJoint(mouse_joint_definition), B2MouseJoint);
    }

    override public function receive(msg: Message): Bool {
        if (Std.isOfType(msg, MouseMove)) {
            if (!isSelected) return false;
            var params = cast(msg, MouseMove);
            var x = params.scenePosition.x + selectedOffset.x;
            var y = params.scenePosition.y + selectedOffset.y;
            mouseJoint.setTarget(new Vector2D(x, y));
            mouseJoint.setMaxForce(10000);

            var b = mouseJoint.getBodyB();
            var a = mouseJoint.getBodyB().getAngle();
            if (a > 0.005)
                b.applyTorque(-1000);
            else if (a < -0.005)
                b.applyTorque(1000);
        }
        return false;
    }
}