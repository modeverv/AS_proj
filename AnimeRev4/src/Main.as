package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import modeverv.movable.ball.Ball;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		private var ball0:Ball;
		private var ball1:Ball;
		private var bounce:Number = -1.0;
		private var numBalls:Number = 10;
		private var balls:Array;
		
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			balls = new Array;
			for (var i:uint = 0; i < numBalls; i++) {
				var ball:Ball = new Ball(Math.random()*80+20,Math.random()*10,Math.random() * 10 -5,Math.random() * 10 -5,Math.random() * 0xffffff);
				ball.x = stage.stageWidth *Math.random();
				ball.y = stage.stageHeight * Math.random();
				addChild(ball);
				balls.push(ball);
			}
			
			ball0 = new Ball(40,2,Math.random() * 10 -5,Math.random() * 10 -5,Math.random() * 0xffffff);
			addChild(ball0);

			ball1 = new Ball(20,1,Math.random() * 10 -5,Math.random() * 10 -5,Math.random() * 0xffffff);
			ball1.x = 100;
			ball1.y = 100;
			ball1.vx = Math.random() * 10 -5;
			ball1.vy = Math.random() * 10 -5;
			addChild(ball1);
			
			addEventListener(Event.ENTER_FRAME, onEF);
		}
		
		private function onEF(e:Event):void {
			for (var i:uint = 0; i < numBalls; i++) {
				var ball:Ball = balls[i] as Ball;
				ball.x += ball.vx;
				ball.y += ball.vy;
				checkWalls(ball);
			}
			for (i = 0; i < numBalls - 1 ; i++) {
				var ballA:Ball = balls[i];
				for (var j:uint = i + 1; j < numBalls; j++) {
					var ballB:Ball = balls[j];
					checkCollision(ballA, ballB);
				}
			}
			
			/*
			ball0.x += ball0.vx;
			ball0.y += ball0.vy;
			ball1.x += ball1.vx;
			ball1.y += ball1.vy;
			checkCollision(ball0, ball1);
			checkWalls(ball0);
			checkWalls(ball1);
			*/
		}
		
		private function checkCollision(ball0:Ball, ball1:Ball):void {
			var dx:Number = ball1.x - ball0.x;
			var dy:Number = ball1.y - ball0.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			if (dist < ball0.radius + ball1.radius) {
				var angle:Number = Math.atan2(dy, dx);
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
				
				var pos0:Point = new Point(0, 0);
				var pos1:Point = rotete(dx, dy, sin, cos, true);
				var vel0:Point = rotete(ball0.vx, ball0.vy, sin, cos, true);
				var vel1:Point = rotete(ball1.vx, ball1.vy, sin, cos, true);

				var vxTotal:Number = vel0.x - vel1.x;
				vel0.x = ((ball0.mass - ball1.mass) * vel0.x + 2 * ball1.mass * vel1.x) / (ball0.mass + ball1.mass);
				vel1.x = vxTotal + vel0.x;
				//pos0.x += vel0.x;
				//pos1.x += vel1.x;
				var absV:Number = Math.abs(vel0.x) + Math.abs(vel1.x);
				var overlap:Number = (ball0.radius + ball1.radius) - Math.abs(pos0.x - pos1.x);				
				pos0.x += vel0.x / absV * overlap;
				pos1.x += vel1.x / absV * overlap;
				
				var pos0F:Object = rotete(pos0.x, pos0.y, sin, cos, false);
				var pos1F:Object = rotete(pos1.x, pos1.y, sin, cos, false);
				ball1.x = ball0.x + pos1F.x;
				ball1.y = ball0.y + pos1F.y;
				ball0.x = ball0.x + pos0F.x;
				ball0.y = ball0.y + pos0F.y;
				var vel0F:Object = rotete(vel0.x, vel0.y, sin, cos, false);
				var vel1F:Object = rotete(vel1.x, vel1.y, sin, cos, false);
				ball0.vx = vel0F.x;
				ball0.vy = vel0F.y
				ball1.vx = vel1F.x;
				ball1.vy = vel1F.y
			}
			
		}
		
		private function rotete(x:Number, y:Number, sin:Number, cos:Number, reverse:Boolean):Point {
			var result:Point = new Point;
			if (reverse) {
				result.x = x * cos + y * sin;
				result.y = y * cos - x * sin;
			}else {
				result.x = x * cos - y * sin;
				result.y = y * cos + x * sin;
			}
			return result;
		}
		
		private function checkWalls(ball:Ball):void {
			if (ball.x + ball.radius > stage.stageWidth) {
				ball.x = stage.stageWidth - ball.radius;
				ball.vx *= bounce;
			}else if (ball.x - ball.radius < 0) {
				ball.x = ball.radius;
				ball.vx *= bounce;
			}
			if (ball.y + ball.radius > stage.stageHeight) {
				ball.y = stage.stageHeight - ball.radius;
				ball.vy *= bounce;
			}else if (ball.y - ball.radius < 0) {
				ball.y = ball.radius;
				ball.vy *= bounce;
			}
		}
	}
	
}