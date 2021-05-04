package hyperKitGLsamples.baseTest;
// Color pallettes
import pallette.simple.QuickARGB;
import trilateral3.drawing.Fill; // triangulate
import trilateral3.drawing.Sketch;
import trilateral3.reShape.QuadShaper;
import trilateral3.shape.IteratorRange;
import trilateral3.reShape.RangeShaper;
import hyperKitGLsamples.imageEncode.Flower;
import trilateral3base.TrilateralBase;
// To trace on screen

import hyperKitGL.DivertTrace;
function main(){
    new Main( 1000, 1000, Flower.png_ );
}

class Main extends TrilateralBase {
    public var quadShaper:          QuadShaper;
    public var posMin:              Int;
    public var outlineStarRange:    IteratorRange;
    public var bgStarOutline        = 0xFFFF0000;
    public var bgStarFill           = 0xFFFFFFFF;
    public var bgQuadFill           = 0xFFFFFFFF; 
    public var starRangeShaper:     RangeShaper;
    var colors = [ Violet, Indigo, Blue, Green, Yellow, Orange, Red ];

    public
    function new( width: Int, height: Int, flower: String ){
        super( width, height, flower );
        
    }
    function firstDraw(){
        drawQuad();
        starDrawing();
    }
    inline
    function drawQuad(){
        // create a quad and populate it with an image
        penTexture.range.start();
        quadShaper       = new QuadShaper( penTexture, penTexture.pos );
        quadShaper.drawQuadColors( 0., 0., 1000., 1000.
                                 , Blue, Green, Yellow, Red );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: true
                                          , range:    penTexture.range.end()
                                          , bgColor:  bgQuadFill };
    }
    
    var outlineTexture = true;
    inline
    function starDrawing(){
        // star outline
        var iterRange = drawStarOutline( outlineTexture, 3, 0xFFffccff );
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: outlineTexture
                                          , range:    iterRange
                                          , bgColor:  bgStarFill };
        // star  fill
        penColor.currentColor = 0xFFffccff;
        penColor.range.start();
        triangulate( penColor, sketchColor, polyK );
        var fillStarRange = penColor.range.end();
        // store for render
        draw_Shape[ draw_Shape.length ] = { textured: false
                                          , range:    fillStarRange
                                          , bgColor:  bgStarOutline };
        starRangeShaper = new RangeShaper( penColor, fillStarRange );
    }
    inline
    function drawStarOutline( useTexture: Bool, size: Float, color: Int ): IteratorRange {
        return switch( useTexture ){
            case true:
                penTexture.currentColor = color;
                penTexture.range.start();
                drawStar( sketchTexture, size );
                outlineStarRange = penTexture.range.end();
            case false:
                penColor.currentColor = color;
                penColor.range.start();
                drawStar( sketchColor, size );
                outlineStarRange = penColor.range.end();
        }
    }
    var theta = 0.;
    function renderAnimate(){
        // how to animate a quad shape.
        quadShaper.xy = { x: quadShaper.xy.x + Math.sin( theta )
                        , y: quadShaper.xy.y };
        starRangeShaper.xy = { x: starRangeShaper.xy.x + Math.sin( theta )
                             , y: starRangeShaper.xy.y };
        theta += 0.1;
    }
    public function drawStar( sketch: Sketch, size: Float ){
        var s = size;
        var sketch = sketchTexture;
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