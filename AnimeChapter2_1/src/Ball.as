package  
{
	import flash.display.Graphics;
	import flash.display.Sprite;
 /**
   * ...
   * @mxmlc -o bin/Ball.swf -load-config+=obj\AnimeChapter2_1Config.xml
   * @author modeverv
   */
  public class Ball
  {
	private var x:Number;
	private var y:Number;
	private var dx:Number;
	private var dy:Number;
	public var c:Number;
		
      	
		public function Ball():void {
			this.x = 0;
			this.y = 0;
			this.dx = 5;
			this.dy = 3;
			this.c = 0x000000;
		}
		public function nextPoint(g:Graphics):void {
			x += dx;
			y += dy;
			c += 0x000001;			
			if (x > 500) {
				x = 0;
			}
			if (y > 500) {
				y = 0;
			}
			g.beginFill(this.c);
			g.drawEllipse(x,y,100,100);
			g.endFill();
		}
    }

  

}