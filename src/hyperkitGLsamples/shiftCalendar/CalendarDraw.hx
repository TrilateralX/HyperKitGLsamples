package hyperKitGLsamples.shiftCalendar;
import trilateral3.reShape.QuadDrawing;
import trilateral3.reShape.QuadShaper;
import pallette.simple.QuickARGB;
class CalendarDraw {
    var datePosX = 17.;
    var datePosY = 17.;
    var datePosW = 39.;
    var datePosH = 39.;
    var dateDeltaX = 3*18.-1.4;
    var dateDeltaY = 3*18.-1.4;
    var monthPosX = 18.+288.-8;
    var monthPosY = 18.-1.4;
    var monthPosW = 180.;
    var monthPosH = 39.;
    var month2PosX = 72. + 18.-3.;
    var month2PosY = 324. + 18.-9.;
    var monthDeltaY = 3*18.-1.4;
    var dateInitX   = new Array<Float>();
    var dateInitY   = new Array<Float>();
    var monInitX    = new Array<Float>();
    var monInitY    = new Array<Float>();
    public var dateQuads  = new Array<QuadShaper>();
    public var monthQuads = new Array<QuadShaper>();
    public var toggles    = new Array<Bool>();
    var quadDrawing: QuadDrawing;
    public function new( quadDrawing_: QuadDrawing ){
        quadDrawing = quadDrawing_;
        generateDates();
        generateMonths();
    }
    public
    function generateDates(){
        var x = datePosX*2;
        var sx = x;
        var y = datePosY*2;

        var dx = dateDeltaX*2;
        var dy = dateDeltaY*2;
        for( i in 0...31 ){
            dateInitX[i] = x;
            dateInitY[i] = y;
            x += dx;
            if( (i+1)%5 == 0 ) {
                y += dy;
                x = sx;
            }
        }
    }
    public inline
    function createDates( px: Float, py: Float, start: Int, len: Int = 31, count: Int, toggleLast: Bool ){
        var x: Float;
        var y: Float;
        var w = datePosW*2;
        var h = datePosH*2;
        var nx = px;
        var ny = py;
        var snx = nx;
        var sny = ny;
        var nw = w/1.2;
        var nh = h/1.2;
        if( start == -1 ) start = 6;
        var ix = start;
        var iStart: Int;
        var iy = 0;
        var quadShaper: QuadShaper;
        if( len > 31 ) len = 31;
        var maxX: Float = 0;
        var toggle = toggleLast;
        
        for( i in 0...len ){
            iStart = i + start;
            x = dateInitX[i];
            y = dateInitY[i];
            // + 1 for 
            if(  (i - 2 + count )%4 == 0 ){
                toggle = !toggle;
            }
            quadShaper = if( toggle ){
                quadDrawing.drawBox( x, y, h, h, SOLID_FILL, 0xFF666666 );
                
            } else {
                quadDrawing.drawBox( x, y, h, h, NONE );
            }
            dateQuads[ dateQuads.length ] = quadShaper;
            //quadShaper.x = 100; //not working!!
            nx = snx + ix*nw;
            ny = sny + iy*nh;
            quadShaper.xy = { x: nx, y: ny };
            quadShaper.dim( nw, nh );
            //
            if( nx > maxX ) maxX = nx;
            ix += 1;
            if( ( iStart+1 )%7 == 0 ) {
                ix = 0;
                iy += 1;
            }
        }
        //nx = snx + ix*nw;
        //ny = sny + iy*nh;
        return { r: maxX + w, b: ny + h, toggleLast: toggle }
    }
    public function generateMonths(){
        var mx = monthPosX*2;
        var my = monthPosY*2;
        var smy = my;
        var mw = monthPosW*2;
        var mh = monthPosH*2;
        var dy = monthDeltaY*2;
        for( i in 0...10 ){
            monInitX[i] = mx;
            monInitY[i] = my;
            my =  smy + i*dy;
        }
        var mx = month2PosX*2;
        var my = month2PosY*2;
        var smy = my;
        var count = 0;
        for( i in 10...13 ){
            monInitX[i] = mx;
            monInitY[i] = my;
            count++;
            my =  smy + count*dy;
        }
    }
    public inline
    function drawMonth( i: Int, px: Float, py: Float ){
        i = i%13;
        var w = monthPosW*2;
        var h = monthPosH*2;
        var x = monInitX[i];
        var y = monInitY[i];
        var quadShaper = quadDrawing.drawBox( x, y, w, h, SOLID_FILL, 0xFFaaaaaa );
        //quadDrawing.drawBox( mx, my, mw, mh, VERT_COLOR_FILL, 0xffff0000, 0xffcc00cc );
        quadShaper.xy = { x: px, y: py };
        quadShaper.dim( w/1.2, h/1.5 );
        monthQuads[ monthQuads.length ] = quadShaper;
        return quadShaper;
    }
    public inline
    function checkMonths(){
        var x: Float;
        var y: Float;
        var mw = monthPosW*2;
        var mh = monthPosH*2;
        var quadShaper: QuadShaper;
        for( i in 0...13 ){
            x = monInitX[i];
            y = monInitY[i];
            var quadShaper = quadDrawing.drawBox( x, y, mw, mh, VERT_COLOR_FILL, 0xffff0000, 0xffcc00cc );
            quadShaper.alpha = 0;
        }
    }
}