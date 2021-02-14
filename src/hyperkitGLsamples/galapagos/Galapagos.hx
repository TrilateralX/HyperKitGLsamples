
package;
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.factories.BitmapObject;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.view.HeapsSimpleView;
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

import trilateral3.geom.Transformer;
import trilateral3.matrix.Vertex;
import trilateral3.Trilateral;

// To trace on screen
import hyperKitGL.DivertTrace;
function main(){
    new Galapagos( 1000, 1000 );
    var divertTrace = new DivertTrace();
    trace("Galapagos example");
}
class Galapagos extends PlyMix {
    var _mesh : Mesh;
    var _view : TrilateralSimpleView;
    var _entityAI : EntityAI;
    var _pathfinder : PathFinder;
    var _path : Array<Float>;
    var _pathSampler : LinearPathSampler;
    var _newPath:Bool = false;
    var x: Float = 0;
    var y: Float = 0;

    var imgBW:      Image;

    var imgColor:   Image;
    public
    function new( width: Int, height: Int ){
        super( width, height );
        trace( 'draw' );
        imageLoader.loadEncoded( [ 'galapagosBW.png','galapagosColor.png'],[ 'galapagosBW','galapagosColor' ] );
    }
    override
    public function draw(){
        var imgBW =  imageLoader.imageArr[ 0 ];
        var w_bw            = imgBW.width;
        var h_bw            = imgBW.height;
        var imgColor =  imageLoader.imageArr[ 1 ];
        var w_color         = imgColor.width;
        var h_color         = imgColor.height;
      /*
        bg.onPush       = function( e ){ onMouseDown( e.button, e.relX, e.relY ); };
        bg.onRelease    = function( e ){ onMouseUp(   e.button, e.relX, e.relY ); };
        bg.onMove       = function( e ){ onMouseMove( e.relX, e.relY ); };
      */
        _view = new TrilateralSimpleView();
        // create pixels from imgBW
        var pixels = hxPixels.Pixels.fromBytes( pixs.bytes, pixs.width, pixs.height );
        // build a rectangular 2 polygons mesh
        _mesh = RectMesh.buildRectangle( 1024, 780 );
        // create viewports
        var object = BitmapObject.buildFromBmpData( pixels, 1.8 );
        object.x = 0;
        object.y = 0;
        _mesh.insertObject( object );
        // we need an entity
        _entityAI = new EntityAI();
        // set radius size for your entity
        _entityAI.radius = 4;
        // set a position
        _entityAI.x = 50;
        _entityAI.y = 50;
        // now configure the pathfinder
        _pathfinder = new PathFinder();
        _pathfinder.entity = _entityAI; // set the entity
        _pathfinder.mesh = _mesh; // set the mesh
        // we need a vector to store the path
        _path = new Array<Float>();
        // then configure the path sampler
        _pathSampler = new LinearPathSampler();
        _pathSampler.entity = _entityAI;
        _pathSampler.samplingDistance = 10;
        _pathSampler.path = _path;
    }
    public function onMouseDown( button: Int, x_: Float, y_: Float ): Void {
        if( button == 0 ){
            x = x_;
            y = y_;
            _newPath = true;
        }
    }
    public function onMouseUp( button: Int, x_: Float, y_: Float ): Void {
        if( button == 0 ){
            x = x_;
            y = y_;
            _newPath = false;
        }
    }
    public function onMouseMove( x_: Float, y_: Float ): Void {
        if( _newPath ){
            x = x_;
            y = y_;
        }
    }
    inline function renderDaedalus( g2: Graphics ){
        // show result mesh on screen
        _view.drawMesh( g2, _mesh );
        if( _newPath ){
            // find path !
            _pathfinder.findPath( x, y, _path );
            // show path on screen
            _view.drawPath( g2, _path );
             // show entity position on screen
            _view.drawEntity( g2, _entityAI ); 
            // reset the path sampler to manage new generated path
            _pathSampler.reset();
        }
        // animate !
        if ( _pathSampler.hasNext ) {
            // move entity
            _pathSampler.next();
        }
        // show entity position on screen
        _view.drawEntity( g2, _entityAI );
    }
    override function update(dt:Float) {
        g.clear();
        renderDaedalus( g );
    }
    static function main() {
        new BitmapPathfinding();
    }
}
