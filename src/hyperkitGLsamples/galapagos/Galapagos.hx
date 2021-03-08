
package hyperKitGLsamples.galapagos;
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.data.Vertex;
import hxDaedalus.factories.BitmapObject;
import hxDaedalus.factories.RectMesh;
import trilateral3.structure.XY;
import hxPixels.Pixels;
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
import trilateral3.nodule.PenTexture;
import trilateral3.nodule.PenColor;
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
import hyperKitGLsamples.galapagos.View;
import trilateral3.structure.RangeEntity;

// To trace on screen
import hyperKitGL.DivertTrace;
function main(){
    new Galapagos( 1000, 1000 );
    var divertTrace = new DivertTrace();
    trace("Galapagos example");
}
//Galapagos based on the example I created for hxDaedalus
class Galapagos extends PlyMix {
    // general setup
    public var penC:                Pen;
    public var penColor             = new PenColor();
    public var penT:                Pen;
    public var penTexture           = new PenTexture();
    
    public var posMin:              Int;
    public var draw_Shape           = new Array<RangeEntity>();
    
    public var quadRange:           IteratorRange;
    public var bgQuadFill           = 0xFFFFFFFF; 
    
    
    // example parameters
    var _mesh:         Mesh;
    var _view:         View;
    var _entityAI:     EntityAI;
    var _pathfinder:   PathFinder;
    var _path:         Array<Float>;
    var _pathSampler:  LinearPathSampler;
    var _newPath:      Bool  = false;
    var x:             Float = 0;
    var y:             Float = 0;
    var imgBW:         Image;
    var imgColor:      Image;
    // fairly generic setups
    inline
    function setupDrawingPens(){
        setupNoduleBuffers();
        penInits();
    }
    inline
    function setupNoduleBuffers(){
        dataGLcolor   = { get_data: penColor.get_data
                        , get_size: penColor.get_size };
        dataGLtexture = { get_data: penTexture.get_data
                        , get_size: penTexture.get_size };
    }
    inline
    function penInits(){
        penC = penColor.pen;
        penC.currentColor = 0xFFFF00FF;
        penT = penTexture.pen;
        penT.useTexture   = true;
        penT.currentColor = 0xffFFFFFF;
    }
    
    public
    function new( width: Int, height: Int ){
        super( width, height );
        trace( 'draw' );
        loadIslandImages();
    }
    inline
    function loadIslandImages(){
        imageLoader.loadEncoded( [ GalapagosBW.png, GalapagosColor.png ]
                               , [ 'galapagosBW',    'galapagosColor'     ] );
    }
    public var quadShaper:          QuadShaper;
    override
    public function draw(){
        trace( imageLoader.imageArr[ 0 ] );
        trace( imageLoader.imageArr[ 1] );
        img =  imageLoader.imageArr[ 1 ];
        var imgBW     = imageLoader.imageArr[ 0 ];
        var w_bw      = imgBW.width;
        var h_bw      = imgBW.height;
        var imgColor  = imageLoader.imageArr[ 1 ];
        var w_color   = imgColor.width;
        var h_color   = imgColor.height;
        var ratio       = 1.; // image ratio.
        // image tranform.
        transformUVArr = [ 2.,0.,0.
                         , 0.,2./ratio,0.
                         , 0.,0.,1.];
      /*
        bg.onPush       = function( e ){ onMouseDown( e.button, e.relX, e.relY ); };
        bg.onRelease    = function( e ){ onMouseUp(   e.button, e.relX, e.relY ); };
        bg.onMove       = function( e ){ onMouseMove( e.relX, e.relY ); };
      */
       mainSheet.mouseDownXY = mouseDownXY;
       mainSheet.mouseUpXY   = mouseUpXY;
       mainSheet.mouseMoveXY = mouseMoveXY;
          
        var surface = mainSheet.cx;
        //surface.drawImage( imgBW, 0, 0, w_bw, h_bw );
        
        setupDrawingPens();
        
        trace( 'draw, ' + penC );
        _view = new View( penColor );
        
        // create pixels from imgBW
        //var pixels          = hxPixels.Pixels.fromBytes( pixs.bytes, pixs.width, pixs.height );
        
        var pixels = Pixels.fromImageData( surface.getImageData(0, 0, w_bw, h_bw ) );
        buildPathFinder( pixels );
        
        testDot();
        //drawQuadBg();
    }
    public function buildPathFinder( pixels ){
        // build a rectangular 2 polygons mesh
        _mesh               = RectMesh.buildRectangle( 1024, 780 );
        // create viewports
        var object          = BitmapObject.buildFromBmpData( pixels, 1.8 );
        object.x            = 0;
        object.y            = 0;
        _mesh.insertObject( object );
        // we need an entity
        _entityAI           = new EntityAI();
        // set radius size for your entity
        _entityAI.radius    = 4;
        // set a position
        _entityAI.x         = 50;
        _entityAI.y         = 50;
        // now configure the pathfinder
        _pathfinder         = new PathFinder();
        _pathfinder.entity  = _entityAI; // set the entity
        _pathfinder.mesh    = _mesh;     // set the mesh
        // we need a vector to store the path
        _path               = new Array<Float>();
        // then configure the path sampler
        _pathSampler        = new LinearPathSampler();
        _pathSampler.entity = _entityAI;
        _pathSampler.samplingDistance = 10;
        _pathSampler.path   = _path;
    }
    public function mouseDownXY( xy: XY ): Void {
        x = xy.x;
        y = xy.y;
        _newPath = true;
    }
    public function mouseUpXY( xy: XY ): Void {
        x = xy.x;
        y = xy.y;
        _newPath = false;
    }
    public function mouseMoveXY( xy: XY ): Void {
        if( _newPath ){
            x = xy.x;
            y = xy.y;
        }
    }
    inline function renderDaedalus(){
        // show result mesh on screen
        _view.drawMesh( _mesh );
        /*
        if( _newPath ){
            // find path !
            _pathfinder.findPath( x, y, _path );
            // show path on screen
            _view.drawPath( _path );
             // show entity position on screen
            _view.drawEntity( _entityAI ); 
            // reset the path sampler to manage new generated path
            _pathSampler.reset();
        }
        // animate !
        if ( _pathSampler.hasNext ) {
            // move entity
            _pathSampler.next();
        }
        // show entity position on screen
        _view.drawEntity( _entityAI );
        */
    }
    override
    public function renderDraw(){
        penC.pos = 0;
        renderDaedalus();
        
        //drawColorShape( 0, Std.int( penColor.pos -1) );
        var count = 0;
        for( a_shape in draw_Shape ){
            switch( a_shape.textured ){
                case true:
                //trace( 'texture draw ' + count );
                count++;
                    drawTextureShape( a_shape.range.start, a_shape.range.max, a_shape.bgColor );
                case false:
                //trace( 'color range ' + a_shape.range );
                count++;
                    drawColorShape( a_shape.range.start, a_shape.range.max );
            }
        }
        tempHackFix();
    }
    inline function drawQuadBg(){
        posMin = Std.int( penT.pos );
        quadShaper       = new QuadShaper( penT, 0 );
        quadShaper.drawQuadColors( 0., 0., 1000., 1000., Blue, Green, Yellow, Red );
        quadRange = posMin...Std.int( penT.pos );
        draw_Shape[ draw_Shape.length ] = { textured: true, range: quadRange, bgColor: bgQuadFill };
    }
    
    inline
    function testDot(){
        posMin = Std.int( penC.pos );
        _view.lineStyle( 40, 0xFFFF0000, 1. );
        _view.drawCircle( 100., 100., 30. );
        //_view.moveTo( 0, 0 );
        //_view.lineTo( 300, 300 );
        trace( penColor.get_size() );
        draw_Shape[ draw_Shape.length ] = 
            { textured: false
            , range:    posMin...Std.int( penC.pos )
            };
        trace( 'draw_Shape.range ' + draw_Shape[ draw_Shape.length - 1].range );
    }
    inline
    function tempHackFix(){
        // need to work out why the color mode needs to be set each frame
        drawTextureShape( 0, 0, 0x00000000 );
    }
}
