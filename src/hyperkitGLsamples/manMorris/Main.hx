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
    public
    function new( width: Int, height: Int, flower: String ){
        super( width, height, flower );
    }
    function firstDraw(){
        trace('** draw/construct 9 men morris  **');
        regular = penColor;
        var board = new NineMorrisBoard( 100., 100., 300. );
        board.generate();
        var n: MorrisNode;
        var nodes = board.morrisNodes;
        var connections = board.connections;
        var starter = penColor.range.start();
        var col = [ 0xffff0000, 0xffff0000, 0xffff0000
                  , 0xff00ff00, 0xff00ff00, 0xff00ff00
                  , 0xfffff000, 0xfffff000, 0xfffff000
                  , 0xfffff0f0, 0xfffff0f0, 0xfffff0f0, 0xfffff0f0, 0xfffff0f0, 0xfffff0f0
                  , 0xff00f0ff, 0xff00f0ff, 0xff00f0ff
                  , 0xFF0000ff, 0xff0000ff, 0xff0000ff
                  , 0xFF00ff00, 0xff00ff00, 0xff00ff00 ];
        for( i in 0...nodes.length ){
            n = nodes[i];
            var p3 = n.pos3D;
            var regularShape: RegularShape = { x: p3.x, y: p3.y, radius: 8, color: col[ i ] };
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
    }
    function renderAnimate(){
        //trace('-- render/animate everything --');
    }
}