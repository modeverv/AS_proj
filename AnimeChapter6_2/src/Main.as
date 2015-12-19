package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import fortest.Ball;
	import net.hires.debug.Stats;
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		private var left:Number = 0;
		private var top:Number = 0;
		private var right:Number = stage.stageWidth;
		private var bottom:Number = stage.stageHeight;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var balls:Array;
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry poin
			//俺俺
			var stats:Stats = new Stats();
			stats.y = 200;
			addChild(stats);
			
			init2();
			
		}
		private var bB:Ball ;
		private var count:Number = 1000;
		private function init2() :void{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			balls = new Array();
			for (var i :int = 0; i < count; ++i) {
				var ball:Ball = initBall();
//				ball.vx = Math.random() * 2 - 1;
//				if (Math.random() >= 0.5) {
//					ball.vx *= -1;
//				}
//				ball.vy = Math.random() * 2 - 1;
//				if (Math.random() >= 0.5) {
//					ball.vy *= -1;
//				}

				addChild(ball);
				balls.push(ball);
				
			}
			
			//跳ね返り
			bB = new Ball(40, 0xff00ff);
			addChild(bB);
			bB.x = Math.random() * stage.stageWidth;
			bB.y = Math.random() * stage.stageHeight;
			bB.vx = 20;// Math.random() * 10 - 1;
			bB.vy = 10;// Math.random() * 10 - 1;
			if (Math.random() > 0.5) { bB.vx *= -1; }
			if (Math.random() > 0.5) { bB.vy *= -1; }
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.ENTER_FRAME, onEnterFrame2);
			
		}
		//跳ね返り with easy fliction
		private var fliction:Number = 0.989;
		private function onEnterFrame2(evt:Event):void {
			//bB.vx *= fliction;
			//bB.vy *= fliction;
			bB.x += bB.vx;
			bB.y += bB.vy;
			var radius:Number = bB.radius;
			//跳ね返り
			var top:Number = 0;
			var left:Number = 0;
			var bottom:Number = stage.stageHeight;
			var right: Number = stage.stageWidth;
			var colorflag:Boolean = false;
			if (bB.x + bB.radius > right) {
				bB.x = right - bB.radius;
				bB.vx *= -1;
				colorflag = true;
			}else if (bB.x - bB.radius < left) {
				bB.x = left + bB.radius;
				bB.vx *= -1;
				colorflag = true;
			}
			if (bB.y +bB.radius > bottom) {
				bB.y = bottom - bB.radius;
				bB.vy *= -1;
				colorflag = true;
			}else if (bB.y - bB.radius < top) {
				bB.y = top + bB.radius;
				bB.vy *= -1;
				colorflag = true;
			}
			if (colorflag) {
				bB.chgColor(Math.random() * 0xffffff);
			}
			if (bB.vx < 5) {
				bB.vx += 0.1;
			}
			if (bB.vy < 5) {
				bB.vy -= 0.1;
			}
		}
		
		private var counta:Number = 0;
		private function initBall():Ball {
				var c:uint = Math.random() * 0xffffff;
				var s:int = Math.random() * 3 + 5;
				var ball:Ball = new Ball(s,c);
				ball.x = Math.random() * stage.stageWidth;
				ball.y = Math.random() * stage.stageHeight;
				trace("born Ball:" + counta++ );
				return ball;
		}
		
		private function onEnterFrame(evt:Event):void {
			for (var i:int = 0; i < balls.length; ++i) {
				var ball:Ball = Ball( balls[i]);
				ball.vx = Math.random() * 2 - 1;
				if (Math.random() >= 0.5) {
					ball.vx *= -1;
				}
				ball.vy = Math.random() * 2 - 1;				
				if (Math.random() >= 0.5) {
					ball.vy *= -1;
				}
				ball.x += ball.vx;
				ball.y += ball.vy;
				if (ball.x - ball.radius > stage.stageWidth ||
					ball.x + ball.radius < 0 ||
					ball.y - ball.radius > stage.stageHeight ||
					ball.y + ball.radius < 0) {
						//スクリーンラッピング 19FPS
						ball.x = stage.stageWidth / 2 * Math.random();
						ball.y = stage.stageHeight / 2 * Math.random();
						//再生成 17FPS
						//removeChild(ball);						
						//balls.splice(i, 1);
						//var ball2:Ball = initBall(); 
						//addChild(ball2)						
						//balls.push(ball2)
						//if (balls.length <= 0) {
						//	removeEventListener(Event.ENTER_FRAME, onEnterFrame);
						//	init()
						//}
					}
				
			}
		}
		
	}
	
}