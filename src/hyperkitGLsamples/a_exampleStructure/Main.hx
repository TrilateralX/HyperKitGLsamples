package hyperKitGLsamples.a_exampleStructure;
import hyperKitGLsamples.imageEncode.Flower;
import trilateral3base.TrilateralBase;
function main(){
    new Main( 1000, 1000, Flower.png_ );
}
class Main extends TrilateralBase {
    public
    function new( width: Int, height: Int, flower: String ){
        super( width, height, flower );
        
    }
    function firstDraw(){
        trace('** draw/construct everything  **');
    }
    function renderAnimate(){
        trace('-- render/animate everything --');
    }
}