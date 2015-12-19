package modeverv.movable.segment {
//	import flash.display.Sprite;
	import modeverv.movable.Movable;
	import flash.geom.Point;
	
	public class Segment extends Movable {

		private var segmentWidth:Number;
		private var segmentHeight:Number;
	
//		public var  vx:Number = 0;
//		public var vy:Number = 0;
		public function Segment(segW:Number = 100, segH:Number = 20, c:uint = 0xffffff) {
			super(c);
			this.segmentWidth = segW;
			this.segmentHeight = segH;
			init();
			
		}
		
		public function init():void {
			//ƒZƒOƒƒ“ƒg‚Ì•`‰æ
			graphics.lineStyle(0);
			graphics.beginFill(color);
			graphics.drawRoundRect( - segmentHeight / 2,
			                                    - segmentHeight / 2,
												segmentWidth + segmentHeight,
												segmentHeight,
												segmentHeight,
												segmentHeight);
			graphics.endFill();
			
			// 2‚Â‚Ìgƒsƒ“h‚Ì•`‰æ
			graphics.drawCircle(0, 0, 2);
			graphics.drawCircle(segmentWidth, 0, 2);
		}
		
		public function getPin():Point
		{
			var angle:Number = rotation * Math.PI / 180;
			var xPos:Number = x + Math.cos(angle) * segmentWidth;
			var yPos:Number = y + Math.sin(angle) * segmentWidth;
			return new Point(xPos, yPos);
		}
		
	}
}