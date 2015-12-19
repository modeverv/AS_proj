package  fortest{
	import flash.display.Sprite;
	
	public class Ball extends Sprite {
		public var radius:Number;
		public var color:uint;
		public var vx:Number = 0;
		public var vy:Number = 0;
		
		
		public function Ball(radius:Number = 40 , color:uint = 0xff0000) {
			this.radius = radius;
			this.color = color;
			this.init();//子クラスoverrideされているときは上書きされたメソッドが呼ばれる。
		}
		
		protected function init():void {
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
		public function chgColor(color:uint):void {
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, radius)
			graphics.endFill();
		}
	}
	
	
}