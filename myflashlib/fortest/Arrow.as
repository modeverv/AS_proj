package  fortest
{
	import flash.display.Sprite;
 /**
   * ...
   * @mxmlc -o bin/Arrow.swf -load-config+=obj\AnimeChapter3_1Config.xml
   * @author modeverv
   */
  public class Arrow extends Sprite
  {
	  private var color:uint;
	  
	 public function Arrow(color:uint=0xffff00) 
    {
		this.color = color;
		init();
      
    }
	public function init():void 
	{
			graphics.lineStyle(1, 0, 1);
			graphics.beginFill(color);
			graphics.moveTo( -50, -25);
			graphics.lineTo(0, -25);
			graphics.lineTo(0, -50);
			graphics.lineTo(50, 0);
			graphics.lineTo(0, 50);
			graphics.lineTo(0, 25);
			graphics.lineTo( -50, 25);
			graphics.lineTo( -50, -25);
			graphics.endFill();
	}

  }

}