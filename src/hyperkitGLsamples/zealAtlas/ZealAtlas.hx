package hyperKitGLsamples.zealAtlas;
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
// To trace on screen
import hyperKitGL.DivertTrace;
import hyperKitGLsamples.zealAtlas.ZealImage;

import hxRectPack2D.output.BodyFrames;
import hxRectPack2D.output.TP;

import hxRectPack2D.atlas.BodyBuilder;
import hxRectPack2D.output.BodyFrames;
import hxRectPack2D.output.LimbFrame;
import hxRectPack2D.rectangle.XYWHF;

import htmlHelper.tools.TextLoader;
import haxe.Resource;
typedef MultipedNode = {
    var name:   String;
    var top:    TopNode;
    var leaves: Array<LeafNode>;
}
typedef TopNode = {
    > LeafNode,
    var x: Float;
    var y: Float;
}
typedef LeafNode = {
    var name:         String;
    var texture:      String;
    var parentName:   String;
    var ox:           Float;
    var oy:           Float;
    var cx:           Float;
    var cy:           Float;
    var rotation:     Float;
}
function main(){
    new ZealAtlas( 1000, 1000 );
    var divertTrace = new DivertTrace();
    trace("Trilateral Zeal Atlas example");
}
class ZealAtlas extends PlyMix {
    public var penColor:            Pen;
    public var penNoduleColor       = new PenArrColor();
    public var penTexture:          Pen;
    public var penNoduleTexture     = new PenArrTexture();
    public var draw_Shape           = new Array<RangeEntity>();
    public var imgW:                Int;
    public var imgH:                Int;
    public var bgQuadFill           = 0x00FFFFFF;
    public var quadShaper:          QuadShaper;
    public var posMin:              Int;
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
        penColor                = penNoduleColor.pen;
        penColor.currentColor   = 0xFFFFFFFF;
        penTexture              = penNoduleTexture.pen;
        penTexture.useTexture   = true;
        penTexture.currentColor = 0xffFFFFFF;
    }
    public function new( width: Int, height: Int ){
        super( width, height );
        trace( 'draw' );
        imageLoader.loadEncoded( [ ZealImage.png ],[ 'zealImage' ] );
    }
    
    inline 
    function setupImage(){
        trace('setupImage');
        img             = imageLoader.imageArr[ 0 ];
        imgW            = img.width;
        imgH            = img.height;
        var ratio       = img.height/img.width; // image ratio.
        // image tranform.
        transformUVArr = [ 2.,0.,0.
                         , 0.,2./ratio,0.
                         , 0.,0.,1.];
        // show original flower.
        showImageOnCanvas( img, imgW, imgH );
    }
    var textLoader: TextLoader;
    override
    public function draw(){
        trace( '__draw ' );
        setupImage();
        setupDrawingPens();
        /*textLoader = new TextLoader( ['zebra_Atlas.json','zebra_Leaf.json' ]
                                   , jsonLoaded, jsonProgress );
        */
        jsonLoaded();
    }
    var inputLimbs:      Array<LimbFrame>;
    var bodyFrames:      BodyFrames;
    var blocks           = new Array<XYWHF>();
    var names            = new Array<String>();
    var multiped: MultipedNode;
    inline
    function bonesData(): { leaf: MultipedNode } {
        return haxe.Json.parse( Resource.getString(  'leafJson' ) );
    }
    public function jsonLoaded(){
        var atlasJsonStr = Resource.getString( 'atlasJson' );
        bodyFrames = new BodyFrames( atlasJsonStr );
        var multi = bonesData();
        var leaves = multi.leaf.leaves;
        inputLimbs = bodyFrames.limbs;
        var i = 0;
        var _        = Std.int;
        for( limb in inputLimbs ){
            names[  i ]  = limb.name;
            blocks[ i ]  = new XYWHF( i, 0, 0, _( limb.w ), _( limb.h ) );
            i++;
        }
        var limbGen: LimbFrame;
        var byName   = bodyFrames.limbByName;
        
        for( i in 0...names.length ){
            limbGen = byName( names[ i ] );
            var quadShaper = drawQuadXYWH( limbGen.x*2
                                         , limbGen.y*2
                                         , limbGen.realW*2.2
                                         , limbGen.realH*2.2
                                         , limbGen.flipped );
            for( l in leaves ){
                // TODO: need to adjust by parent, more work see Xperimental
                if( l.texture == names[i] ){
                    quadShaper.xy = { x: l.ox, y: l.oy };
                    quadShaper.startU = l.ox;
                    quadShaper.startV = l.oy;
                }
            }
            if( names[i]== 'body.png' ) bodyShaper = quadShaper;
        }
    }
    var bodyShaper: QuadShaper;
    inline
    function drawQuadXYWH( x: Float, y: Float, w: Float, h: Float, rotate: Bool ){
        posMin = Std.int( penTexture.pos );
        // create a quad and populate it with an image
        var quadShaper       = new QuadShaper( penTexture, penTexture.pos );
        quadShaper.drawQuad( x, y, w, h );
        var quadRange = posMin...Std.int( penTexture.pos );
        if( rotate ) {
            quadShaper.rook_90();
        }
        draw_Shape[ draw_Shape.length ] = { textured: true
                                          , range:    quadRange
                                          , bgColor:  bgQuadFill };
        return quadShaper;
    }
    public function jsonProgress( str: String ){
        trace( 'progress loaded ' + str );
    }
    var theta = Math.PI/100;
    override
    public function renderDraw( ){
        var haveTextures: Bool = false;
        var haveColors:   Bool = false;
        bodyShaper.rotateFromCentre( bodyShaper.width/2, bodyShaper.height/2, theta );
        for( a_shape in draw_Shape ){
            switch( a_shape.textured ){
                case true:
                    haveTextures = true;
                    drawTextureShape( a_shape.range.start
                                    , a_shape.range.max
                                    , a_shape.bgColor );
                case false:
                    haveColors = true;
                    drawColorShape( a_shape.range.start
                                  , a_shape.range.max );
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