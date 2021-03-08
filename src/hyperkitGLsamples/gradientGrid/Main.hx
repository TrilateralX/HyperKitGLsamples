package hyperKitGLsamples.gradientGrid;
// Color pallettes
import pallette.simple.QuickARGB;
import pallette.utils.ColorInt;
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

// To trace on screen
import hyperKitGL.DivertTrace;
function main(){
    var divertTrace = new DivertTrace();
    new Main( 1000, 1000, false, true );
    
    trace("Gradient Grid Test");
}

class Main extends PlyMix {
    public var penColor:            Pen;
    public var penNoduleColor       = new PenColor();
    public var posMin:              Int;
    public var quadRange:           IteratorRange;
    public var draw_Shape           = new Array<RangeEntity>();
    inline
    function setupDrawingPens(){
        setupNoduleBuffers();
        penInits();
    }
    // connects data buffers to pen drawing.
    inline
    function setupNoduleBuffers(){
        dataGLcolor   = { get_data: penNoduleColor.get_data
                        , get_size: penNoduleColor.get_size };
    }
    inline
    function penInits(){
        penColor = penNoduleColor.pen;
        penColor.currentColor = 0xFFFFFFFF;
    }
    
    override
    public function draw(){
        // setup
        setupDrawingPens();
        drawQuad();
    }
    inline
    function drawQuad(){
        posMin = Std.int( penColor.pos );
        // create a grid of quad and populate it with an image
        var sx = 100;
        var sy = 100;
        var px = sx;
        var py = sy;
        var dx = 10;
        var dy = 10;
        var ds = 0;
        var iy = 0;
        var ix = 0;
        // make sure functions don't output more than 0 to 1.
        var fRed = function( x: Float, y: Float ): Float {
            var rx = radAdj( x );
            return sin01( rx - Math.PI/2 );
        }
        var fGreen = function( x: Float, y: Float ): Float {
            var rx = radAdj( x );
            var ry = radAdj( y );
            return ( sin01( rx ) + cos01( ( ry * rx - Math.PI/2 - 0.1 ) * 20 ))/2;
        }
        var fBlue = function( x: Float, y: Float ): Float {
            return 0.6;
        }
        for( iy in 0...100 ){
            for( ix in 0...100 ){
                // creates four color gradient square
                var quadShaper       = new QuadShaper( penColor, ds );
                ds+=2;
                var delta = 1/10;
                var colorA = genColors( ix * delta, iy * delta, fRed, fGreen, fBlue );
                var colorB = genColors( (ix + 1 )* delta, iy * delta, fRed, fGreen, fBlue );
                var colorC = genColors( ( ix + 1 ) * delta, ( iy + 1 ) * delta, fRed, fGreen, fBlue );
                var colorD = genColors( ix * delta, ( iy + 1 ) * delta, fRed, fGreen, fBlue );
                quadShaper.drawQuadColors( px *1.1, py* 1.1, dx, dy
                                         , colorA, colorB, colorC, colorD );
                px += dx;
            }
            px = sx;
            py += dy;
        }
        quadRange = posMin...Std.int( penColor.pos );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: false
                                          , range: quadRange };
        // this should not be needed!!
        setAnimate();
    }
    inline function radAdj( r: Float ){
        return r*Math.PI/50;
    }
    inline function sin01( r: Float ){
        return 0.5+(Math.sin( r )/2);
    }
    inline function cos01( r: Float ){
        return 0.5+(Math.cos( r )/2);
    }
    inline
    public function genColors( x: Float, y: Float
                             , fRed:   ( x: Float , y: Float ) -> Float
                             , fGreen: ( x: Float, y: Float )-> Float
                             , fBlue:  ( x: Float, y: Float )-> Float ): ColorInt {
        var col: ColorInt = 0xFF000000;
        col.red   = fRed( x, y );
        col.green = fGreen( x, y );
        col.blue  = fBlue( x, y );
        return col;
    }
    var theta = 0.;
    override
    public function renderDraw(){
        for( a_shape in draw_Shape ){
            switch( a_shape.textured ){
                case true:
                    drawTextureShape( a_shape.range.start, a_shape.range.max, a_shape.bgColor );
                case false:
                    drawColorShape( a_shape.range.start, a_shape.range.max );
            }
        }
    }
}