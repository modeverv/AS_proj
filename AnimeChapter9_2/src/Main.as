package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	import flash.events.MouseEvent;
	import fortest.Ball;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		private var balls:Array;
		private var numBalls:Number = 100;
		private var bounce :Number = - 0.7;
		private var spring:Number = .1;
		private var gravity:Number = 0.9;
		private var fliction:Number = 0.9;
		private var mode:Number = 3;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;			
			var stats:Stats = new Stats()
			stats.y = 200;
			addChild(stats);
			
			init2();

		}
		private function init2() {
						balls  = new Array();
			for (var i:Number = 0; i < numBalls; ++i) {
				var ball :Ball = new Ball(Math.random() * 20 + 10,
													Math.random() * 0xffffff);
				ball.x = Math.random() * stage.stageWidth;
				ball.y = Math.random() * stage.stageHeight;
				ball.vx = Math.random() * 6 - 3;
				ball.vy = Math.random() * 6 - 3;
				addChild(ball);
				balls.push(ball);
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDobleClick);
			
		}
		
		private function onMouseDobleClick(event:MouseEvent):void {
			for (var i:Number = 0; i < numBalls ; ++i) {
				removeChild(balls[i]);				
			}
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDobleClick);
			init2();
		}
		
		private function onEnterFrame(event:Event):void {
			for (var i:uint = 0 ; i < numBalls - 1; i++) {
				var ball0:Ball = balls[i];
				for (var j:uint = i + 1; j  < numBalls ; j++) {
					var ball1:Ball = balls[j];
					var dx:Number = ball1.x - ball0.x;
					var dy:Number = ball1.y - ball0.y;
					var dist :Number = Math.sqrt(dx * dx + dy * dy);
					var minDist:Number = ball0.radius + ball1.radius;
					if (dist < minDist) {
						var angle:Number = Math.atan2(dy, dx);
						var tx:Number = ball0.x + Math.cos(angle) * minDist;
						var ty:Number = ball0.y + Math.sin(angle) * minDist;
						var ax :Number = (tx - ball1.x) * spring;
						var ay:Number = (ty - ball1.y) * spring;
						if(mode >= 2){
						ball0.chgColor(Math.random() * 0xffffff);
						}
						if(mode >= 3){
						ball1.chgColor(Math.random() * 0xffffff);
						}
						ball0.vx -= ax;
						ball0.vy -= ay;
						ball1.vx += ax;
						ball1.vy += ay;
					}
				}
				
			}
			for (i = 0 ;i < numBalls; ++i) {
				var ball:Ball = balls[i];
				move(ball);
			}

		}
		
		private function move(ball:Ball):void {
			ball.vy += gravity;
			ball.x += ball.vx * fliction;
			ball.y += ball.vy * fliction;
			if (ball.x + ball.radius > stage.stageWidth) {
				ball.x = stage.stageWidth - ball.radius;
				ball.vx *= bounce;
			}else if (ball.x - ball.radius < 0){
				ball.x = ball.radius;
				ball.vx *= bounce;
			}
			if (ball.y + ball.radius > stage.stageHeight) {
				ball.y = stage.stageHeight - ball.radius;
				ball.vy *= bounce;
			}else if(ball.y - ball.radius < 0){
				ball.y = ball.radius;
				ball.vy *= bounce;
			}
		}
		
	}
	
}