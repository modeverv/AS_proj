package  fortest{
	import flash.display.Sprite;
	
	public class Box extends Sprite {
		public var w:Number ;
		public var h:Number;
		public var color:uint = 0xff00ff;
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		
		public function Box(wi:Number = 50,he:Number=50 , c:uint = 0xff0000) {
			this.w = wi;
			this.h = he;
			this.color = c;
			init();			
		}
		public function chgColor(c:uint = 0xff0000):void {
			graphics.clear();
			color = c;
			init();
		}
		public function init():void {
			graphics.beginFill(color);
			graphics.drawRect(-w / 2,-h / 2,w,h);
			graphics.endFill();
		}
	}
	
	
}