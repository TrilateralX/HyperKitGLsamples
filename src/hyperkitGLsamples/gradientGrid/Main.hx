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
import trilateral3.nodule.PenArrColor;
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
import trilateral3.reShape.GradientGrid;
// To trace on screen
import hyperKitGL.DivertTrace;
function main(){
    var divertTrace = new DivertTrace();
    new Main( 1000, 1000, false, true );
    
    trace("Gradient Grid Test");
}

class Main extends PlyMix {
    public var penColor:            Pen;
    public var penNoduleColor       = new PenArrColor();
    public var posMin:              Int;
    public var quadRange:           IteratorRange;
    public var draw_Shape           = new Array<RangeEntity>();
    public var gradientGrid:        GradientGrid;
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
        setAnimate();
    }
    inline
    function drawQuad(){
        gradientGrid = new GradientGrid( penColor );
        // make sure functions don't output more than 0 to 1.
        var radAdj = GradientGrid.radAdj;
        var sin01  = GradientGrid.sin01;
        var cos01  = GradientGrid.cos01;
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
        quadRange = gradientGrid.addGrid( 100, 100, 1000, 1000, 60, 60, 0.1, 0.1, fRed, fGreen, fBlue );
        draw_Shape[ draw_Shape.length ] = { textured: false
                                          , range: quadRange };
        // this should not be needed!!
    }
    var theta = 0.1;
    override
    public function renderDraw(){
        var radAdj = GradientGrid.radAdj;
        var sin01  = GradientGrid.sin01;
        var cos01  = GradientGrid.cos01;
        var fRed = function( x: Float, y: Float ): Float {
            var rx = radAdj( x );
            return sin01( rx - Math.PI/2 );
        }
        var fGreen = function( x: Float, y: Float ): Float {
            var rx = radAdj( x ) + theta;
            var ry = radAdj( y ) + theta;
            return ( sin01( rx ) + cos01( ( ry * rx - Math.PI/2 - 0.1 ) * 20 ))/2;
        }
        var fBlue = function( x: Float, y: Float ): Float {
            return 0.6;
        }
        gradientGrid.modifyColor( 0.1, 0.1, fRed, fGreen, fBlue );
        theta += 0.002;
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