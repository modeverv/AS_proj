package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import modeverv.movable.ball.Ball;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		
		private var balls:Array;
		private var numBalls:Number = 30;
		private var bounce:Number = -0.5;
		private var spring:Number = 0.03;
		private var gravity:Number = .7;
		
		private var friction:Number = .7;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			balls = new Array();
			
			for (var i:uint = 0; i < numBalls; i++) {
				var ball:modeverv.movable.ball.Ball = new modeverv.movable.ball.Ball(Math.random() * 20 + 20, 1, 1, Math.random() * 0xffffff);
				ball.x = Math.random() * stage.stageWidth;
				ball.y = Math.random() * stage.stageHeight;
				ball.vx = Math.random() * 6 - 3;
				ball.vy = Math.random() * 6 - 3;
				addChild(ball);
				balls.push(ball);
			}
			addEventListener(Event.ENTER_FRAME, onEF);
		}
		
		private function onEF(e:Event):void {
			for (var i:uint = 0; i < numBalls -1; i++) {
				var ball0:Ball = balls[i];
				for (var j:uint = i + 1; j  < numBalls ; j++) {
					var ball1:Ball = balls[j];
					var dx:Number = ball1.x - ball0.x;
					var dy:Number = ball1.y - ball0.y;
					var dist:Number = Math.sqrt(dx * dx + dy * dy);
					var minDist:Number = ball0.radius + ball1.radius;
					if (dist < minDist) {
						var angle:Number = Math.atan2(dy, dx);
						var tx:Number = ball0.x + Math.cos(angle) * minDist;
						var ty:Number = ball1.y + Math.sin(angle) * minDist;
						var ax:Number = (tx - ball1.x) * spring;
						var ay:Number = (ty - ball1.y) * spring;
						ball0.vx -= ax;
						ball0.vy -= ay;
						ball1.vx += ax;
						ball1.vy += ay;
						ball0.vx *= friction;
						ball0.vy *= friction;
					}
				}
			}
			for (i = 0; i < numBalls; i++) {
				var ball:Ball = balls[i];
				move(ball);
			}
		}
			
		private function move(ball:modeverv.movable.ball.Ball):void {
			ball.vy += gravity;
			ball.x += ball.vx;
			ball.y += ball.vy;
			if (ball.x + ball.radius > stage.stageWidth) {
				ball.x = stage.stage.stageWidth - ball.radius;
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