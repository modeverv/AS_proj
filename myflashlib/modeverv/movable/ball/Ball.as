package modeverv.movable.ball 
{
	import flash.events.Event;
	import modeverv.movable.Weight;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Ball extends Weight
	{
		public var radius:Number;
		
		public static var XCOLLISION:String = ("XCOLLISION");
		public static var YCOLLISION:String = ("YCOLLISION");
		
		public function Ball(radius:Number=20,_mass:Number=10, _vx:Number=10,_vy:Number=10,c:uint=0xff00ff) 
		{
			super(_mass,_vx, _vy, c);
			this.radius = radius;
			init();
		}
		private function init():void {
			graphics.beginFill(super.color);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
		
		override public function chgColor(c:uint):void 
		{
			super.chgColor(c);
			graphics.beginFill(super.color);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
		
		public function doRebound(limitX:Number, limitY:Number, rebound:Number = 0.1):void {
			if (this.x + radius>= limitX) {
//				trace("rebound X");
				vx *= -1 * rebound;
				x = limitX - radius;
				dispatchEvent(new Event(Ball.XCOLLISION));
			} else if (this.x  <= radius) {
//				trace("rebound X");
				vx *= -1 * rebound;
				x = radius;
				dispatchEvent(new Event(Ball.XCOLLISION));
			} 
			
			if (this.y + radius >= limitY) {
//				trace("rebound Y");
				vy *= -1 * rebound;
				y = limitY - radius;
				dispatchEvent(new Event(Ball.YCOLLISION));
			}else if (this.y <= radius) {
//				trace("rebound Y");
				vy *= -1 * rebound;
				y = radius;
				dispatchEvent(new Event(Ball.YCOLLISION));
			}
			
		}
		
		
	}

}