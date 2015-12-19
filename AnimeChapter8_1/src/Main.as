package 
{
	//easing
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
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var ball:Ball;
		private var easing:Number = 0.3;
		private var targetX :Number = stage.stageWidth / 2;
		private var targetY:Number = stage.stageHeight / 2;
		
		private var balls:Array;
		private var ballcount:Number = 1000;
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;			
			var stats:Stats = new Stats()
			stats.y = 200;
			addChild(stats);
			
			ball = new Ball();
			ball.x = Math.random() * stage.stageWidth;
			ball.y = Math.random() * stage.stageHeight;
			
			addChild(ball);
			
			balls = new Array();
			for (var i:int = 0 ; i < ballcount; ++i) {
				var _b:Ball = new Ball(Math.random() * 2 + 10, 0xffff00);
				addChild(_b);
				_b.x = Math.random() * stage.stageWidth;
				_b.y = Math.random() * stage.stageHeight;
				balls.push(_b);
			}
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			
		}
		private function onMouseDown(event:Event):void {
			ball.x = Math.random() * stage.stageWidth;
			ball.y = Math.random() * stage.stageHeight;			
		}
		private var b:Ball;
		private var vx2:int;
		private var vy2:int;
		private function onEnterFrame(event:Event):void {
			var red:Number = 255;
			var green :Number = 0; 
			var blue:Number = 0; 
			var redTarget:Number = 0;
			var greenTarget:Number = 255;
			var blueTarget:Number = 255;
			
			var targetColor:uint = 0xffffff;
			var dcolor:uint = (targetColor - ball.color) * easing;
			ball.chgColor(dcolor);
			
			var vx :Number  = (mouseX - ball.x) * easing;
			var vy:Number = (mouseY - ball.y) * easing;
			ball.x += vx; ball.y += vy;
			if (Math.abs(ball.x - targetX) < 10  && Math.abs(ball.y - targetY) < 10) {
				removeChild(ball);
				ball = new Ball(Math.random() * 40 + 10,Math.random() * 0xffffff);
				ball.x = Math.random() * stage.stageWidth;
				ball.y = Math.random() * stage.stageHeight;

			
				
				addChild(ball);
			}
			easing -= 0.001;
			trace(easing);
			
			for (var i:int = 0; i < ballcount; ++i) {
				b= Ball(balls[i]);
				vx2  = (targetX - b.x) * easing;
				vy2 = (targetY - b.y) * easing;
				b.x += vx2; b.y += vy2;
				//b.x += mouseX; b.y += mouseY;
				if (Math.abs(b.x - targetX) < 10  && Math.abs(b.y - targetY) < 10) {
					//removeChild(b);
					//balls.splice(i, 1);
					//b = new Ball(Math.random() * 40 + 10,Math.random() * 0xffffff);
					b.x = Math.random() * stage.stageWidth;
					b.y = Math.random() * stage.stageHeight;
					//easing -= 0.001;
					//addChild(b);
				}
			}
			if (easing < 0.01) {
				easing = 0.5
				//removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				trace("over");
			}
		}
		
	}
	
}