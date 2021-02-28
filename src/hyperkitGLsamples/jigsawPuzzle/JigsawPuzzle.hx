package hyperKitGLsamples.jigsawPuzzle;
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

import trilateral3.geom.Transformer;
import trilateral3.matrix.Vertex;
import trilateral3.Trilateral;
import hyperKitGLsamples.sliderPuzzle.TableCloth;

// To trace on screen
import hyperKitGL.DivertTrace;
function main(){
    new JigsawPuzzle( 1000, 1000 );
    var divertTrace = new DivertTrace();
    trace("JigsawPuzzle example");
}
class JigsawPuzzle extends PlyMix {
    public var penColor:            Pen;
    public var penNoduleColor       = new PenColor();
    public var penTexture:          Pen;
    public var penNoduleTexture     = new PenTexture();
    
    public var theta                = 0.;
    public var quadDepth:           QuadDepth;
    public var firstRange:          IteratorRange;
    public var pieces               = new Array<QuadShaper>();
    public var origPositions        = new Array<XY>();
    public var curPositions         = new Array<XY>();
    public var mouseVertex:         Vertex;
    public var emptyPos:            XY;
    public var historyCount         = new Array<Int>();
    //var movePiece                   = 1;
    var colors                      = [ Violet, Indigo, Blue, Green, Yellow, Orange, Red, Red ];
    var horizontal                  = true;
    public var sketch:              Sketch;
    //var pixelRatio:                 Float;
    var wasHit:                     Bool = true;
    var ratio:                      Float;
    var nW:                         Int = 7;
    var nH:                         Int = 4;
    var dw:                         Float;
    var dh:                         Float;
    var loop                        = 0;
    var first1                      = true;
    var itemCounter:                Int;
    public
    function new( width: Int, height: Int ){
        super( width, height );
        trace( 'draw' );
        imageLoader.loadEncoded( [ TableCloth.png ],[ 'tableCloth' ] );
    }
    
}
