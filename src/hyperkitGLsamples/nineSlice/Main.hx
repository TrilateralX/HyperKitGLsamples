package hyperKitGLsamples.nineSlice;
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
import trilateral3.reShape.NineSlice;
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
    public var penNoduleColor       = new PenArrColor();
    public var penTexture:          Pen;
    public var penNoduleTexture     = new PenArrTexture();
    public var sketch:              Sketch;
    public var posMin:              Int;
    public var draw_Shape           = new Array<RangeEntity>();
    public var imgW:                Int;
    public var imgH:                Int;
    public var nineSlice:           NineSlice;
    public var bgColor             = Violet;
    var colors = [ Violet, Indigo, Blue, Green, Yellow, Orange, Red ];
    
    inline
    function setupDrawingPens(){
        trace('setupDrawingPens');
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
        loadButtonImage();
    }
    inline 
    function loadButtonImage(){
        // built in load images
        imageLoader.loadEncoded( [ ButtonImage.png ],[ 'ButtonImage' ] );
    }
    inline 
    function setupImage(){
        trace('setupImage');
        img             =  imageLoader.imageArr[ 0 ];
        imgW            = img.width;
        imgH            = img.height;
        var ratio       = img.height/img.width;
        // image tranform.
        transformUVArr = [ 2.,0.,0.
                         , 0.,2./ratio,0.
                         , 0.,0.,1.];
        // show original flower.
        //showImageOnCanvas( img, imgW, imgH );
    }
    override
    public function draw(){
        trace( '__draw ' );
        // setup
        setupImage();
        setupDrawingPens();
        //setupSketch();
        // drawing examples
        nineSlice = new NineSlice( penTexture );
        nineSlice.addSlices( 0, 0, 1024, 1024, 200, 200, 600, 600, 0xFFFFFFFF );
        var nineRange = 0...18;
        var red = 0xFFFF0000;
        var yellow = 0xFFFFFF00;
        nineSlice.modifyColors( Red, Orange, Yellow, Green
                             , Orange, Orange, Yellow, Green
                             , Yellow, Yellow, Green, Blue
                             , Green, Green, Blue, Blue );
        draw_Shape[ draw_Shape.length ] = { textured: true
                                          , range:    nineRange
                                          , bgColor:  bgColor };
        trace('drew everything');
    }
    var theta = 0.;
    var count = 0;
    var count2 = 0;
    var tick = 0.;
    var border:{ bLeft: Float, bRight: Float
               , bTop: Float, bBottom: Float };
    override
    public function renderDraw(){
        var haveTextures: Bool = false;
        var haveColors:   Bool = false;
        var c = Math.cos(theta);
        var s = Math.sin(theta);
        tick+= 0.01;
        count = Math.round( tick );
        count2 = colors.length - 1 - count;
        if( count > colors.length - 1 ) tick = 0.;
        nineSlice.scaleBorder( 1 + c/200, true );
        nineSlice.dim( Math.abs( 400*c ) + 600, Math.abs( 300*s ) + 600 );
        nineSlice.modifyColors( colors[count2], colors[count2], colors[count2], colors[count2]
                             , colors[count], Red, White, colors[count]
                             , colors[count2], Yellow, Blue, colors[count2]
                             , colors[count], colors[count], colors[count], colors[count] );
        theta+= 0.01;
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
}