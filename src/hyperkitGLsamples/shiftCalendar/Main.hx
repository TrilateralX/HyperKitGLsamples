package hyperKitGLsamples.shiftCalendar;
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
import trilateral3.reShape.RangeShaper;
import trilateral3.reShape.QuadDrawing;
import hyperKitGLsamples.shiftCalendar.CalendarDraw;
// To trace on screen
import hyperKitGL.DivertTrace;
function main(){
    new Main( 1000, 1000 );
    var divertTrace = new DivertTrace();
    trace("Shift example");
}
enum abstract QuadColorFill(Int){
    var NONE;
    var SOLID_FILL;
    var VERT_COLOR_FILL;
    var HORI_COLOR_FILL;
    var QUAD_COLOR_FILL;
}
class Main extends PlyMix {
    var penColor:            Pen;
    var penNoduleColor       = new PenArrColor();
    var penTexture:          Pen;
    var penNoduleTexture     = new PenArrTexture();
    var sketch:              Sketch;
    var posMin:              Int;
    var draw_Shape           = new Array<RangeEntity>();
    var imgW:                Int;
    var imgH:                Int;
    var bgColor             = White;
    var colors = [ Violet, Indigo, Blue, Green, Yellow, Orange, Red ];
    var bgQuadFill           = 0x00000000; 
    var quadDrawing:         QuadDrawing;
    var calendarDraw:        CalendarDraw;
    inline
    function setupDrawingPens(){
        trace('setupDrawingPens');
        setupNoduleBuffers();
        penInits();
    }
    
    public
    function new( width: Int, height: Int ){
        super( width, height );
        trace( 'draw' );
        loadButtonImage();
        // white alpha background
        bgA = 0.5;
        bgR = 0.4;
        bgG = 0.1;
        bgB = 0.0;
    }
    inline 
    function loadButtonImage(){
        // built in load images
        imageLoader.loadEncoded( [ CalendarGraphic.png ],[ 'CalendarGraphic' ] );
    }
    inline 
    function setupImage(){
        trace('setupImage');
        img             =  imageLoader.imageArr[ 0 ];
        imgW            = img.width;
        imgH            = img.height;
        // image tranform.
        transformUVArr = [ 2.,0.,0.
                         , 0.,2.,0.
                         , 0.,0.,1.];
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
        drawCalendarDetails();
        trace('drawn everything');
    }
    public inline
    function drawCalendarDetails(){
        quadDrawing = new QuadDrawing( penTexture, draw_Shape );
        calendarDraw = new CalendarDraw( quadDrawing );
        var x = 100.;
        var y = 0.;
        var today : ShiftDateTime = '2021-04-07 16:53:00';
        var count = 7;
        var data = drawMonthDate( x, y, today, count, false );
        y = data.rb.b;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
        y = data.rb.b;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
        // next row
        var x = data.rb.r;
        var y = 0.;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
        y = data.rb.b;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
        y = data.rb.b;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
        var x = data.rb.r;
        var y = 0.;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
        y = data.rb.b;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
        y = data.rb.b;
        var data = drawMonthDateNext( x, y, data.today, data.count, data.rb.toggleLast );
    }
    public inline 
    function drawMonthDateNext( x: Float, y: Float, today: ShiftDateTime, count: Int, toggleLast: Bool ){
        var today : ShiftDateTime = today.getAnotherDay( today.daysMonth() );
        return drawMonthDate( x, y, today, count, toggleLast );
    }
    public inline
    function drawMonthDate( x: Float, y: Float, today: ShiftDateTime, count: Int, toggleLast: Bool ){
        calendarDraw.drawMonth( today.getMonth(), x-5, y );
        var noDays = today.daysMonth();
        var rb = calendarDraw.createDates( x, y + 80, today.getFirstWeekDay() - 1, noDays, count, toggleLast );
        count += noDays;
        return { rb: rb, today: today, count: count };
    }
    // --- More generic code --- //
    
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
    override
    public function renderDraw(){
        var haveTextures: Bool = false;
        var haveColors:   Bool = false;
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