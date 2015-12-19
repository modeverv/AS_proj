package  
{
	import flash.display.Sprite;
	
 /**
   * ...
   * @mxmlc -o bin/Bobbin.swf -load-config+=obj\AnimeChapter3_1Config.xml
   * @author modeverv
   */
  public class Bobbin extends Sprite
  {
	private var  radius:Number;
	private var color:uint;
    public function Bobbin(radius:Number = 40,color:uint=0xff0000) 
    {
      this.radius = radius;
	  this.color = color;
	  init();
    }
	private function init():void {
		graphics.beginFill(color);
		graphics.drawCircle(0, 0, radius);
		graphics.endFill();
	}
		
		

  }

}