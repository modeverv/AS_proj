package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import modeverv.movable.ball.Ball;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		
		private var b:Ball;
		private var lines:Array;
		private var numLines:uint = 5;
		private var gravity:Number = 0.3;
		private var bouce:Number = -0.6;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			b = new Ball;
			addChild(b);
			b.x = 100;
			b.y = 50;
			
			lines = new Array();
			for (var i:uint = 0; i < numLines; i++) {
				var line:Sprite = new Sprite;
				line.graphics.lineStyle(1);
				line.graphics.moveTo( -50, 0);
				line.graphics.lineTo(50, 0);
				addChild(line);
				lines.push(line);
			}
			lines[0].x = 100;
			lines[0].y = 100;
			lines[0].rotation = 30;
			
			lines[1].x = 100;
			lines[1].y = 230;
			lines[1].rotation = 45;
			
			lines[2].x = 250;
			lines[2].y = 180;
			lines[2].rotation = -30;

			lines[3].x = 150;
			lines[3].y = 330;
			lines[3].rotation = 10;
			
			lines[4].x = 230;
			lines[4].y = 250;
			lines[4].rotation = -30;
			
			addEventListener(Event.ENTER_FRAME, onEF);
			stage.addEventListener(MouseEvent.CLICK, onMD);
		}
		private function onMD(e:MouseEvent):void {
			b.x = 100;
			b.y = 50;
		}
		private function onEF(e:Event):void {
			b.vy += gravity;
			b.x += b.vx;
			b.y += b.vy;
			
			if (b.x + b.radius > stage.stageWidth)  {
				b.x = stage.stageWidth - b.radius;
				b.vx *= bouce;
			}else if (b.x -b.radius < 0) {
				b.x = b.radius;
				b.vx *= bouce;
			}
			if (b.y + b.radius > stage.stageHeight) {
				b.y = stage.stageHeight - b.radius;
				b.vy *= bouce;
			}else if (b.y - b.radius < 0) {
				b.y = b.radius;
				b.vy *= bouce;
			}
			
		  for (var i:uint = 0; i < numLines; i++) {
				checkLine(lines[i]);
			}
		}
		
		private function checkLine(line:Sprite):void {
			var bounds:Rectangle = line.getBounds(this);
			if (b.x > bounds.left && b.x < bounds.right) {
				var angle:Number = line.rotation * Math.PI / 180;
				var cos:Number = Math.cos(angle);
				var sin:Number = Math.sin(angle);
				
				var x1:Number = b.x - line.x;
				var y1:Number = b.y -line.y;
				
				var y2:Number = cos * y1 - sin * x1;
				var vy1:Number = cos * b.vy - sin * b.vx;
				if (y2 > - b.height / 2 && y2 < vy1) {
					var x2:Number = cos * x1 + sin * y1;
					var vx1:Number = cos * b.vx + sin * b.vy;
					y2 = -b.height / 2;
					vy1 *= bouce
					x1 = cos * x2 - sin * y2;
					y1 = cos * y2 + sin * x2;
					b.vx = cos  * vx1 - sin * vy1;
					b.vy = cos * vy1 + sin * vx1 ;
					b.x = line.x + x1;
					b.y = line.y + y1;
				}
			}
		}
	}
}