package hyperKitGLsamples.manMorris;
// Color pallettes
import pallette.simple.QuickARGB;
import js.Browser;
import js.html.MouseEvent;
import js.html.Event;
import js.html.Image;
import js.html.KeyboardEvent;
import hyperKitGL.PlyMix;
import hyperKitGL.DataGL;
import haxe.Timer;
// Sketching
import trilateral3.drawing.Pen;
import trilateral3.nodule.PenColor;
import trilateral3.nodule.PenTexture;
import trilateral3.nodule.PenArrColor;
import trilateral3.nodule.PenArrTexture;
import trilateral3.shape.IteratorRange;
import hyperKitGL.ImageGL;
import hyperKitGL.BufferGL;
import trilateral3.drawing.StyleEndLine;
import trilateral3.drawing.Sketch;
import trilateral3.drawing.StyleSketch;
import trilateral3.drawing.Fill;
import hyperKitGL.GL;
import trilateral3.reShape.RangeShaper;
import trilateral3.reShape.QuadShaper;
import trilateral3.structure.XY;
import trilateral3.reShape.QuadDepth;
import trilateral3.shape.IteratorRange;
import trilateral3.geom.Transformer;
import trilateral3.matrix.Vertex;
import trilateral3.Trilateral;
import trilateral3.structure.RangeEntity;
import hyperKitGLsamples.imageEncode.Flower;
import trilateral3base.TrilateralBase;
import trilateral3.structure.RegularShape;
import trilateral3.shape.Regular;
import trilateral3.reShape.DepthArray;
import trilateral3.reShape.RangeDepth;
// morrisMen
import morrisMen.MorrisNode;
import morrisMen.NineMorrisBoard;
// To trace on screen
import hyperKitGL.DivertTrace;
function main(){
    new Main( 1000, 1000, Flower.png_ );
    trace("manMorris example");
}

class Main extends TrilateralBase {
    var regular: Regular;
    var rangeDepth: RangeDepth;
    var itemCounter:                Int;
    public
    function new( width: Int, height: Int, flower: String ){
        super( width, height, flower );
    }
    function firstDraw(){
        trace( '** draw/construct 9 men morris  **' );
        regular = penColor;
        var board = new NineMorrisBoard( 100., 100., 300. );
        board.generate();
        var n: MorrisNode;
        var nodes = board.morrisNodes;
        var connections = board.connections;
        var starter = penColor.range.start();
        rangeDepth = new RangeDepth( penColor, 24 );
        var col = [ 0xffff0000, 0xffff0000, 0xffff0000
                  , 0xff00ff00, 0xff00ff00, 0xff00ff00
                  , 0xfffff000, 0xfffff000, 0xfffff000
                  , 0xfffff0f0, 0xfffff0f0, 0xfffff0f0, 0xfffff0f0, 0xfffff0f0, 0xfffff0f0
                  , 0xff00f0ff, 0xff00f0ff, 0xff00f0ff
                  , 0xFF0000ff, 0xff0000ff, 0xff0000ff
                  , 0xFF00ff00, 0xff00ff00, 0xff00ff00 ];
        for( i in 0...nodes.length ){
            n = nodes[i];
            var r = Std.random( 3 );
            var piece: Piece_ = r;
            var p = new Piece( r );
            n.contain = p;
        }
        for( i in 0...nodes.length ){
            n = nodes[i];
            var pos1 = penColor.pos;
            var p3 = n.pos3D;
            var regularShape: RegularShape = { x: p3.x, y: p3.y, radius: 12, color: col[ i ] };
            switch( n.contain ){
                case NONE: 'NONE';
                    regularShape.color = 0x00FFFFFF;
                    regularShape.radius = 30;
                case PLAY0: "PLAY0";
                    regularShape.color = 0xFFFF0000;
                    regularShape.radius = 30;
                case PLAY1: "PLAY1";
                    regularShape.color = 0xFF0000FF;
                    regularShape.radius = 30;
                case _: 
                // 
            }
            if( n.contain != NONE ){
                regular.circle( regularShape );
                var circleRange: IteratorRange = penColor.range.difEnd();
                rangeDepth.addShape( new RangeShaper( penColor, circleRange ) );
            }
        }
        for( i in 0...nodes.length ){
            n = nodes[i];
            var pos1 = penColor.pos;
            var p3 = n.pos3D;
            var regularShape: RegularShape = { x: p3.x, y: p3.y, radius: 12, color: col[ i ] };
            regularShape.color = 0xFFFFFFFF;
            regular.circle( regularShape );
        }
        var c: MorrisConnection;
        penColor.currentColor = 0xFFffccff;
        for( i in 0...connections.length ){
            c = connections[i];
            sketchColor.moveTo( c.a.x, c.a.y );
            sketchColor.lineTo( c.b.x, c.b.y );
        }
        draw_Shape[ draw_Shape.length ] = { textured: false
                                          , range:    penColor.range.end()
                                          };   
                                                                       
        mainSheet.mouseDownSetup();
        mainSheet.mouseDownXY = mouseDownXY;
        mainSheet.mouseUpXY   = mouseUpXY;
        mainSheet.mouseMoveXY = mouseMoveXY;
    }
    public var historyCount         = new Array<Int>();
    var tempX: Float = 0;
    var tempY: Float = 0;
    var wasHit: Bool = true;
    var movePiece = false;
    var t = 0.;
    var step = 0.12;  
    public function mouseDownXY( xy: XY ){
        if( movePiece ) return;
        movePiece = true;
        step = 0.06;
        // #if trilateral_hitDebug 
          //    var dist = quadDepth.distHit( mxy.x, mxy.y );
            //  trace( dist ); #end 
        hitTile( xy );
    }
    
    public
    function mouseUpXY( xy: XY ){
        mainSheet.mouseDragStop();
    }
    
    public function mouseMoveXY( xy: XY ){
        if( movePiece ) return;
        if( wasHit ) {
            var px = xy.x - tempX;
            var py = xy.y - tempY;
            rangeDepth.setXY( itemCounter, px, py );
        }
    }
    inline
    function hitTile( mxy: XY ){
        trace( 'hitTile ');
        var results = rangeDepth.fullHit( mxy.x, mxy.y );
        trace( results );
        wasHit = results[0] != null;
        if( wasHit ) {
            mainSheet.mouseDownDisable();
            var countNo = results[ 0 ]; // since results are in depth order.    
            moveTile( countNo, true, mxy );
            mainSheet.mouseMoveSetup();
        } else {
            movePiece = true;
        }
    }
    
    inline
    function moveTile( countNo: Int, allowHistory: Bool, ?mxy: XY ){
        itemCounter = countNo;
        var xy = rangeDepth.getXY( countNo );
        if( mxy != null ) storeHitOffset( xy, mxy );
        //rangeDepth.toTopCount( countNo );
        movePiece   = false;
    }
    inline
    function storeHitOffset( xy: XY, mxy: XY ){
        tempX = ( mxy.x - xy.x );
        tempY = ( mxy.y - xy.y );
    }
    function renderAnimate(){
        //trace('-- render/animate everything --');
    }
}