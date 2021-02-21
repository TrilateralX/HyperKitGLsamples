package hyperKitGLsamples.basic;
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
import trilateral3.nodule.PenPaint;
import trilateral3.nodule.PenNodule;
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
    new Main( 1000, 1000 );
    var divertTrace = new DivertTrace();
    trace("Basic example");
}

class Main extends PlyMix {
    public var penColor:            Pen;
    public var penNoduleColor       = new PenNodule();
    public var penTexture:          Pen;
    public var penNoduleTexture     = new PenPaint();
    public var quadShaper:          QuadShaper;
    public var sketch:              Sketch;
    public var posMin:              Int;
    public var outlineStarRange:    IteratorRange;
    public var fillStarRange:       IteratorRange;
    public var quadRange:           IteratorRange;
    public var bgStarOutline        = 0xFFFF0000;
    public var bgStarFill           = 0xFFFFFFFF;
    public var bgQuadFill           = 0xFFFFFFFF; 
    public var draw_Shape           = new Array<RangeEntity>();
    public var starRangeShaper:     RangeShaper;
    var colors = [ Violet, Indigo, Blue, Green, Yellow, Orange, Red, Red ];
    public
    function new( width: Int, height: Int ){
        super( width, height );
        trace( 'draw' );
        imageLoader.loadEncoded( [ Flower.png ],[ 'Flower' ] );
    }
    override
    public function draw(){
        img =  imageLoader.imageArr[ 0 ];
        var w            = img.width;
        var h            = img.height;
        var ratio = 1.;
        //showImageOnCanvas( img, w, h );
        setupDrawingPens();
        posMin = Std.int( penTexture.pos );
        quadShaper       = new QuadShaper( penTexture, 0 );
        quadShaper.drawQuad( 0., 0., 1000., 1000. );
        quadRange = posMin...Std.int( penTexture.pos );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: true, range: quadRange, bgColor: bgQuadFill };
        
        sketch           = new Sketch( penTexture, StyleSketch.Fine, StyleEndLine.no );
        
        sketch.width     = 40;
        
        // star outline
        var iterRange = drawStarOutline( true, 3, 0xFFffccff );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: true, range: iterRange, bgColor: bgStarFill };
        
        // start fill
        penColor.currentColor = 0xFFffccff;
        posMin = Std.int( penColor.pos );
        triangulate( penColor, sketch, polyK );
        fillStarRange = posMin...Std.int( penColor.pos -1 );
        
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: false, range: fillStarRange, bgColor: bgStarOutline };
        starRangeShaper = new RangeShaper( penColor, fillStarRange );
        transformUVArr = [ 2.,0.,0.
                         , 0.,2./ratio,0.
                         , 0.,0.,1.];
    }
    inline
    function drawStarOutline( useTexture: Bool, size: Float, color: Int ): IteratorRange {
        return switch( useTexture ){
            case true:
                penTexture.currentColor = color;
                posMin = Std.int( penTexture.pos );
                drawStar( sketch, size );
                outlineStarRange = posMin...Std.int( penTexture.pos - 1 );
            case false:
                penColor.currentColor = 0xFFffccff;
                posMin = Std.int( penColor.pos );
                drawStar( sketch, size );
                outlineStarRange = posMin...Std.int( penColor.pos - 1 );
        }
    }
    var theta = 0.;
    override
    public function renderDraw(){
        var haveTextures: Bool = false;
        var haveColors:   Bool = false;
        quadShaper.xy = { x: quadShaper.xy.x + Math.sin( theta ), y: quadShaper.xy.y };
        //starRangeShaper.setXY( {x: 0, y: 0 } );//0.1*Math.sin( theta ) } );
        theta += 0.1;
        for( a_shape in draw_Shape ){
            switch( a_shape.textured ){
                case true:
                    haveTextures = true;
                    drawTextureShape( a_shape.range.start, a_shape.range.max, a_shape.bgColor );
                case false:
                    haveColors = true;
                    drawColorShape( a_shape.range.start, a_shape.range.max );
            }
        }
        if( !haveColors ) tempHackFix();
    }
    
    public function tempHackFix(){
        // need to work out why the color mode needs to be set each frame
        drawColorShape( 0, 0 );
    }
    inline
    function showImageOnCanvas( img: Image, wid: Int, hi: Int ){
        mainSheet.cx.drawImage( img, 0, 0, wid, hi );
    }
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
        dataGLtexture = { get_data: penNoduleTexture.get_data
                        , get_size: penNoduleTexture.get_size };
    }
    inline
    function penInits(){
        penColor = penNoduleColor.pen;
        penColor.currentColor = 0xFFFFFFFF;
        penTexture = penNoduleTexture.pen;
        penTexture.useTexture   = true;
        penTexture.currentColor = 0xffFFFFFF;
    }
    public function drawStar( sketch: Sketch, size: Float ){
        var s = size;
        sketch.moveTo( 121*s, 111*s );
        sketch.moveTo( 150*s, 25*s );
        sketch.lineTo( 179*s, 111*s );
        sketch.lineTo( 269*s, 111*s );
        sketch.lineTo( 197*s, 165*s );
        sketch.lineTo( 223*s, 251*s );
        sketch.lineTo( 150*s, 200*s );
        sketch.lineTo( 77*s,  251*s );
        sketch.lineTo( 103*s, 165*s );
        sketch.lineTo( 31*s,  111*s );
        sketch.lineTo( 121*s, 111*s );
        sketch.lineTo( 150*s, 25*s );
        sketch.lineTo( 179*s, 111*s );
    }
}