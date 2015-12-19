package  
{
	import flash.display.Sprite;
	
 /**
   * ...
   * @mxmlc -o bin/Ship.swf -load-config+=obj\AnimeChapter5_3Config.xml
   * @author modeverv
   */
  public class Ship extends Sprite
  {

    public function Ship() 
    {
		draw(false);
    }
	
	public function draw(shoeFlame:Boolean):void {
		graphics.clear();
		graphics.lineStyle(1, 0xff0000);
		graphics.moveTo(10, 0);
		graphics.lineTo(-10, 10);
		graphics.lineTo( -5, 0);
		graphics.lineTo( -10, -10);
		graphics.lineTo(10, 0)
	
		if (shoeFlame) {
			graphics.moveTo( -7.5, -5);
			graphics.lineTo( -15, 0);
			graphics.lineTo( -7.5, 5);			
		}
		
	}

  }

}