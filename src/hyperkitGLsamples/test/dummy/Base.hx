package dummy;

class Base{
    public var width:            Int;
    public var height:           Int;
    public var animate:          Bool;
    public var hasImage:         Bool = true;
    public function new( width_: Int, height_: Int
                      , ?hasImage: Bool = true
                      , ?animate: Bool = true ){
                          animate = this.animate;
                          width  = width_;
                          height = height_;
                          //creategl();
                          this.hasImage = hasImage;
                          if( hasImage ) {
                              //imageLoader = new ImageLoader( [], setup );
                          } else {
                              setup();
                          }
    }
    public function setup(){
        trace('setup');
    }
}