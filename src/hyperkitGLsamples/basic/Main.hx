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
    new Main( 1000, 1000 );
    var divertTrace = new DivertTrace();
    trace("Basic example");
}

class Main extends PlyMix {
    // always required
    public var penColor:            Pen;
    public var penNoduleColor       = new PenColor();
    public var penTexture:          Pen;
    public var penNoduleTexture     = new PenTexture();
    
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
    public var imgW:                Int;
    public var imgH:                Int;
    
    var colors = [ Violet, Indigo, Blue, Green, Yellow, Orange, Red, Red ];
    
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
    
    public
    function new( width: Int, height: Int ){
        super( width, height );
        trace( 'draw' );
        loadFlower();
    }
    inline 
    function loadFlower(){
        // built in load images
        imageLoader.loadEncoded( [ Flower.png ],[ 'Flower' ] );
    }
    inline 
    function setupImage(){
        img             =  imageLoader.imageArr[ 0 ];
        imgW            = img.width;
        imgH            = img.height;
        var ratio       = 1.; // image ratio.
        // image tranform.
        transformUVArr = [ 2.,0.,0.
                         , 0.,2./ratio,0.
                         , 0.,0.,1.];
        // show original flower.
        //showImageOnCanvas( img, imgW, imgH );
    }
    override
    public function draw(){
        // setup
        setupImage();
        setupDrawingPens();
        setupSketch();
        // drawing examples
        drawQuad();
        starDrawing();
    }
    inline 
    function setupSketch(){
        if( outlineTexture ){
            sketch       = new Sketch( penTexture, StyleSketch.Fine, StyleEndLine.no );
        } else {
            sketch       = new Sketch( penColor, StyleSketch.Fine, StyleEndLine.no );
        }
        sketch.width     = 40;
    }
    inline
    function drawQuad(){
        posMin = Std.int( penTexture.pos );
        // create a quad and populate it with an image
        quadShaper       = new QuadShaper( penTexture, 0 );
        quadShaper.drawQuad( 0., 0., 1000., 1000. );
        quadRange = posMin...Std.int( penTexture.pos );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: true, range: quadRange, bgColor: bgQuadFill };
    }
    var outlineTexture = true;
    inline
    function starDrawing(){
        
        // star outline
        var iterRange = drawStarOutline( outlineTexture, 3, 0xFFffccff );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: outlineTexture, range: iterRange, bgColor: bgStarFill };
        // star  fill
        penColor.currentColor = 0xFFffccff;
        posMin = Std.int( penColor.pos );
        triangulate( penColor, sketch, polyK );
        fillStarRange = posMin...Std.int( penColor.pos -1 );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: false
                                          , range:    fillStarRange
                                          , bgColor:   bgStarOutline };
        starRangeShaper = new RangeShaper( penColor, fillStarRange );
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
                penColor.currentColor = color;//0xFFffccff;
                posMin = Std.int( penColor.pos );
                drawStar( sketch, size );
                outlineStarRange = posMin...Std.int( penColor.pos - 1 );
                trace( 'outlineStarRange ' + outlineStarRange );
                outlineStarRange= posMin...Std.int( penColor.pos - 1 );
        }
    }
    var theta = 0.;
    override
    public function renderDraw(){
        var haveTextures: Bool = false;
        var haveColors:   Bool = false;
        // how to animate a quad shape.
        quadShaper.xy = { x: quadShaper.xy.x + Math.sin( theta ), y: quadShaper.xy.y };
        // rangeshaper animation needs more work in trilateral.
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