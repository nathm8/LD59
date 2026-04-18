package graphics;

import gamelogic.physics.PhysicalWorld.PHYSICSCALE;
import h2d.Scene;
import h2d.Graphics;
import box2D.dynamics.B2DebugDraw;
import box2D.common.math.B2Vec2;
import box2D.common.math.B2Transform;
import box2D.common.B2Color;

class HeapsDebugDraw extends B2DebugDraw {
    
    var graphics: Graphics;

    public function new(parent: Scene) {
        super();
        graphics = new Graphics();
        graphics.alpha = 0.5;
        parent.add(graphics, 0);
        setFlags(B2DebugDraw.e_shapeBit);
        m_drawScale = PHYSICSCALE;
    }

    override public function clear() {
        graphics.clear();
    }

    /**
     * Draw a closed polygon provided in CCW order.
     */
     override public function drawPolygon(vertices:Array<B2Vec2>, vertexCount:Int, color:B2Color):Void
        {
            #if heaps
            graphics.lineStyle(m_lineThickness, color.color, m_alpha);
            graphics.moveTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
            for (i in 1...vertexCount)
            {
                graphics.lineTo(vertices[i].x * m_drawScale, vertices[i].y * m_drawScale);
            }
            graphics.lineTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
            #end
        }
    
        /**
         * Draw a solid closed polygon provided in CCW order.
         */
        override public function drawSolidPolygon(vertices:Array<B2Vec2>, vertexCount:Int, color:B2Color):Void
        {
            #if heaps
            // fill polygon
            graphics.moveTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
            graphics.beginFill(color.color, m_fillAlpha);
            for (i in 1...vertexCount)
            {
                graphics.lineTo(vertices[i].x * m_drawScale, vertices[i].y * m_drawScale);
            }
            graphics.lineTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
            graphics.endFill();
    
            // draw polygon edges
            drawPolygon(vertices, vertexCount, color);
            #end
        }
    
        /**
         * Draw a circle.
         */
        override public function drawCircle(center:B2Vec2, radius:Float, color:B2Color):Void
        {
            #if heaps
            graphics.lineStyle(m_lineThickness, color.color, m_alpha);
            graphics.drawCircle(center.x * m_drawScale, center.y * m_drawScale, radius * m_drawScale, 12);
            #end
        }
    
        /**
         * Draw a solid circle.
         */
        override public function drawSolidCircle(center:B2Vec2, radius:Float, axis:B2Vec2, color:B2Color):Void
        {
            #if heaps
            graphics.beginFill(color.color, m_fillAlpha);
            graphics.drawCircle(center.x * m_drawScale, center.y * m_drawScale, radius * m_drawScale, 12);
            graphics.endFill();
            graphics.lineStyle(m_lineThickness, color.color, m_alpha);
            graphics.moveTo(0, 0);
            graphics.moveTo(center.x * m_drawScale, center.y * m_drawScale);
            graphics.lineTo((center.x + axis.x * radius) * m_drawScale, (center.y + axis.y * radius) * m_drawScale);
            #end
        }
    
        /**
         * Draw a line segment.
         */
        override public function drawSegment(p1:B2Vec2, p2:B2Vec2, color:B2Color):Void
        {
            #if heaps
            graphics.lineStyle(m_lineThickness, color.color, m_alpha);
            graphics.moveTo(p1.x * m_drawScale, p1.y * m_drawScale);
            graphics.lineTo(p2.x * m_drawScale, p2.y * m_drawScale);
            #end
        }
    
        /**
         * Draw a transform. Choose your own length scale.
         * @param xf a transform.
         */
        override public function drawTransform(xf:B2Transform):Void
        {
            #if heaps
            graphics.lineStyle(m_lineThickness, 0xff0000, m_alpha);
            graphics.moveTo(xf.position.x * m_drawScale, xf.position.y * m_drawScale);
            graphics.lineTo((xf.position.x + m_xformScale * xf.R.col1.x) * m_drawScale, (xf.position.y + m_xformScale * xf.R.col1.y) * m_drawScale);
    
            graphics.lineStyle(m_lineThickness, 0x00ff00, m_alpha);
            graphics.moveTo(xf.position.x * m_drawScale, xf.position.y * m_drawScale);
            graphics.lineTo((xf.position.x + m_xformScale * xf.R.col2.x) * m_drawScale, (xf.position.y + m_xformScale * xf.R.col2.y) * m_drawScale);
            #end
        }
    
}