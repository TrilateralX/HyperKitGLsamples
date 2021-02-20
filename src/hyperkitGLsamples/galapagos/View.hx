package hyperKitGLsamples.galapagos;
import wings.core.ISimpleDrawingContext;
import trilateral3.nodule.PenPaint;
// Sketching
import trilateral3.drawing.StyleEndLine;
import trilateral3.drawing.Sketch;
import trilateral3.drawing.StyleSketch;
import trilateral3.drawing.Fill;
import trilateral3.drawing.Pen;
import trilateral3.geom.FlatColorTriangles;
import trilateral3.nodule.PenNodule;
import trilateral3.shape.Shaper;
import trilateral3.shape.Regular;
import trilateral3.structure.RegularShape;

import hxDaedalus.data.Vertex;
import hxDaedalus.data.Face;
import hxDaedalus.data.Edge;
import hxDaedalus.data.Mesh;
import hxDaedalus.ai.EntityAI;
import hxDaedalus.iterators.FromMeshToVertices;
import hxDaedalus.iterators.FromVertexToHoldingFaces;
import hxDaedalus.iterators.FromVertexToIncomingEdges;
import hxDaedalus.data.Face;
import hxDaedalus.iterators.FromFaceToInnerEdges;
import hxDaedalus.data.math.Point2D;

typedef DPoint2D = hxDaedalus.data.math.Point2D;
//typedef PVertex = phoenix.geometry.Vertex;

class View {
    
    public var edgesColor:Int = 0x999999;
    public var edgesWidth:Float = 1;
    public var edgesAlpha:Float = .25;
    public var constraintsColor:Int = 0xFF0000;
    public var constraintsWidth:Float = 2;
    public var constraintsAlpha:Float = 1.0;
    public var verticesColor:Int = 0x0000FF;
    public var verticesRadius:Float = .5;
    public var verticesAlpha:Float = .25;
    public var pathsColor:Int = 0xFF00FF;//FFC010;
    public var pathsWidth:Float = 1.5;
    public var pathsAlpha:Float = .75;
    public var entitiesColor:Int = 0x00FF00;
    public var entitiesWidth:Float = 1;
    public var entitiesAlpha:Float = .75;
    public var faceColor: Int = 0xff00ff;
    public var faceWidth: Float = 1;
    public var faceAlpha: Float = .5;
    public var faceToEdgeIter = new FromFaceToInnerEdges();
    
    var _prevX:Float = 0;
    var _prevY:Float = 0;
    var _lineColor:Int;
    var _fillColor:Int;
    var _inFillingMode:Bool = false;
    var sketch: Sketch;
    var pen: Pen;
    var regular: Regular;
    
    public function new( nodulePen: PenNodule ){//paintPen: PaintPen ) {
        //pen = paintPen.pen;
        pen = nodulePen.pen;
        regular = new Regular( pen );
        lineSketch();
    }
    public function clear():Void {
        // not yet implemented
    }
    public function lineStyle( thickness: Float, color: Int, ?alpha: Float = 1 ): Void {
        sketch.width = thickness;
        _lineColor = color;
        if( !_inFillingMode ) pen.currentColor = color;
    }
    
    public function moveTo(x:Float, y:Float):Void {
        _prevX = x;
        _prevY = y;
        sketch.moveTo( x, y );
    }

    public function beginFill(color:Int, ?alpha:Float = 1):Void {
        _fillColor = color;
        pen.currentColor = _fillColor;
        // alpha to implement
        //_fillColor.a = alpha;
        _inFillingMode = true;
        fillSketch();
    }
    
    function fillSketch(){
        if( sketch != null ) sketch.reset();
        sketch = new Sketch( pen, StyleSketch.FillOnly, StyleEndLine.no );
    }

    function lineSketch(){
        if( sketch != null ) sketch.reset();
        sketch = new Sketch( pen, StyleSketch.Crude, StyleEndLine.no );
    }
    
    public function endFill():Void {
        _inFillingMode = false;
        pen.currentColor = _lineColor;
        lineSketch();
    }
    
    public function quadTo( cx: Float, cy: Float, ax: Float, ay: Float ):Void {
        sketch.quadTo( cx, cy, ax, ay );
    }

    public function lineTo( x: Float, y: Float ):Void {
        sketch.lineTo( x, y );
    }

    public function drawTri( points:Array<Float> ){
        //if( _inFillingMode ){
            sketch.moveTo( points[0], points[1] );
            sketch.lineTo( points[2], points[3] );
            sketch.lineTo( points[4], points[5] );
            sketch.lineTo( points[0], points[1] );
        /*} else {
            pen.addTriangle( points[0], points[1]
                           , points[2], points[3]
                           , points[4], points[5] );
        }*/
    }

    // These shapes assumes not called durring Fill, may need some more thought on trilateral3 implementation details.
    
    public function drawCircle( cx:Float, cy:Float, radius: Float ):Void { 
        pen.currentColor = _fillColor;
        circle( pen.paintType, cx, cy, radius );
        pen.currentColor = _lineColor;
    }
   
    public function drawRect(x:Float, y:Float, width:Float, height:Float):Void {    
        pen.quad2DFill( x, y, width, height, _fillColor );
        pen.currentColor = _lineColor;
    }
///
    public function drawEquilaterialTri( x: Float, y: Float, radius: Float, direction: Float ):Void {
        regular.triangle( { x: x, y: y, radius: radius, color: _fillColor } );
        pen.currentColor = _lineColor;
        // not implemented yet
        //pen.drawType.transform( transformMatrix );
    }
    inline public function circle_( p: { x: Float, y: Float }, radius: Float, color: Int, alpha: Float ){
        lineStyle( entitiesWidth, entitiesColor, entitiesAlpha );
        beginFill( entitiesColor, entitiesAlpha );
        drawCircle( p.x, p.y, radius );
        endFill();
    }
    /*
    inline public function label(  p: { x: Float, y: Float }, t: String, font: Font, fontSize: Int, color: Int, alpha: Float ){
        // not implemented
    }*/
    inline public function lineP( p0: { x: Float, y: Float }, p1: { x: Float, y: Float }
                                ,   color: Int, alpha: Float, strength: Float ){
        lineStyle( strength, color, alpha );
        moveTo( p0.x, p0.y );
        lineTo( p1.x, p1.y );
    }
    public function drawVertex( vertex : Vertex): Void {
        circle_( vertex.pos, verticesRadius, verticesColor, verticesAlpha );
        #if showVerticesIndices
            // todo add font!
            // label( p, new Point( vertex.pos.x + 5, vertex.pos.y + 5, font, fontSize, 0xFFFFFFFF, verticesAlpha );
        #end
    }
    public function drawFace( face: Face ) : Void {
        faceToEdgeIter.fromFace = face;
        var count = 0;
        var edge;
        beginFill( faceColor, faceAlpha );
        lineStyle( faceWidth, faceColor, faceAlpha );
        var p: Point2D;
        while( true ){
            edge = faceToEdgeIter.next();
            if( edge == null ) break;
            p = edge.originVertex.pos;
            if( count == 0 ) moveTo( p.x, p.y );
            p = edge.destinationVertex.pos;
            lineTo( p.x, p.y );
            count++;
        }
    }
    public function drawEdge( edge : Edge ): Void {
        var p0 = edge.originVertex.pos;
        var p1 = edge.destinationVertex.pos;
        if( edge.isConstrained ){
            lineP( p0, p1, constraintsColor, constraintsAlpha, constraintsWidth );
        } else {
            lineP( p0, p1, edgesColor, edgesAlpha, edgesWidth );
        }
    }
    public function drawMesh( mesh: Mesh ): Void {
        var all = mesh.getVerticesAndEdges();
        for (v in all.vertices) drawVertex( v );
        for (e in all.edges) drawEdge( e );
    }
    public function drawEntity( entity: EntityAI ): Void {
        circle_( entity, entity.radius, entitiesColor, entitiesAlpha );
    }
    public function drawEntities( vEntities:Array<EntityAI> ): Void {
        for (i in 0...vEntities.length) drawEntity( vEntities[ i ] );
    }
    public function drawPath( path:Array<Float>, cleanBefore:Bool = false): Void {
        if (path.length == 0) return;
        lineStyle( pathsWidth, pathsColor, pathsWidth );
        moveTo( path[0], path[1] );
        var i = 2;
        while( i < path.length ) {
          lineTo( path[ i ], path[ i + 1 ] );
          i += 2;
        }
    }
    
}