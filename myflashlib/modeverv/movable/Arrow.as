package modeverv.movable 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author modeverv
	 */
	public class Arrow extends Movable
	{

		public static var XCOLLISION:String = ("XCOLLISION");
		public static var YCOLLISION:String = ("YCOLLISION");
		
		public function Arrow(_vx:Number=10,_vy:Number=10,c:uint=0xff00ff) 
		{
			super(_vx, _vy, c);
			init();
		}
		private function init():void {
			graphics.lineStyle(2, super.color, 1);
			graphics.beginFill(super.color);
			graphics.moveTo( -50, -25);
			graphics.lineTo(0, -25);
			graphics.lineTo(0, -50);
			graphics.lineTo(50, 0);
			graphics.lineTo(0, 50);
			graphics.lineTo(0, 25);
			graphics.lineTo(-50, 25);
			graphics.lineTo(-50, -25);
			graphics.endFill();
		}
		
		override public function chgColor(c:uint):void 
		{
			super.chgColor(c);
			graphics.lineStyle(2, super.color, 1);
			graphics.beginFill(super.color);
			graphics.moveTo( -50, -25);
			graphics.lineTo(0, -25);
			graphics.lineTo(0, -50);
			graphics.lineTo(50, 0);
			graphics.lineTo(0, 50);
			graphics.lineTo(0, 25);
			graphics.lineTo(-50, 25);
			graphics.lineTo(-50, -25);
			graphics.endFill();
		}
		
		//与えられた方へ矢印の方向を向ける
		public function pointXY(_x:Number, _y:Number):void 
		{
			var dy:Number = _y - y;
			var dx:Number = _x - x;
			var radians:Number = Math.atan2(dy, dx);
			this.rotation = radians * 180 / Math.PI;
		}
		
		public function doRebound(limitX:Number, limitY:Number, rebound:Number = 0.1):void {
			if (this.x + 100 >= limitX) {
//				trace("rebound X");
				vx *= -1 * rebound;
				x = limitX - 100;
				dispatchEvent(new Event(Arrow.XCOLLISION));
			} else if (this.x  <= 100) {
//				trace("rebound X");
				vx *= -1 * rebound;
				x = 100;
				dispatchEvent(new Event(Arrow.XCOLLISION));
			} 
			
			if (this.y + 100 >= limitY) {
//				trace("rebound Y");
				vy *= -1 * rebound;
				y = limitY - 100;
				dispatchEvent(new Event(Arrow.YCOLLISION));
			}else if (this.y <= 100) {
//				trace("rebound Y");
				vy *= -1 * rebound;
				y = 100;
				var ev:Event = new Event(Arrow.YCOLLISION);
				dispatchEvent(ev);
			}
			
		}
		
	}

}