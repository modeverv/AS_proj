package 
{
	//spring
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
		
		private var ball :Ball;
		private var ball1 :Ball;
		private var ball2 :Ball;
		private var spring:Number = 0.1;
		private var targetX:Number = stage.stageWidth / 2;
		private var targetY :Number = stage.stageHeight / 2;
		private var vx:Number = 0;
		private var vy:Number = 0;
		private var vx1:Number = 0;
		private var vy1:Number = 0;		
		private var vx2:Number = 0;
		private var vy2:Number = 0;
		
		private var fliction:Number = 0.85;
		private var gravity :Number = 10; 
		private var gravity1 :Number = 5; 
		private var gravity2 :Number = 45; 
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;			
			var stats:Stats = new Stats()
			stats.y = 200;
			addChild(stats);			
			
			ball = new Ball (40,0xff0000);
			addChild(ball);
			ball.y = 0;//stage.stageHeight / 2;
			ball.x = 0;
			ball1 = new Ball (20,0x00ff00);
			addChild(ball1);
			ball1.y = 0;//stage.stageHeight / 2;
			ball1.x = 0;
			ball2 = new Ball (65,0x0000ff);
			addChild(ball2);
			ball2.y = 0;//stage.stageHeight / 2;
			ball2.x = 0;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		private function onEnterFrame(event:Event):void {
			
			
			
			//var dx :Number = targetX - ball.x ;
			var dx :Number = mouseX - ball.x ;
			var ax :Number = dx * spring;
			vx += ax;
			vx *= fliction;
			ball.x += vx;
			
			//var dy:Number = targetY - ball.y;
			var dy:Number = mouseY - ball.y;
			var ay:Number = dy * spring;
			vy += ay;
			vy += gravity;
			vy *= fliction;
			ball.y += vy;
			
			graphics.clear();---------------------------
			graphics.lineStyle(1);
			graphics.moveTo(ball.x, ball.y);1
			graphics.lineTo(mouseX, mouseY);
			
			
			
						//var dx :Number = targetX - ball.x ;
			var dx1 :Number =  ball.x  - ball1.x;
			var ax1 :Number = dx1 * spring;
			vx1 += ax1;
			vx1 *= fliction;
			ball1.x += vx1;
			
			//var dy:Number = targetY - ball.y;
			var dy1:Number = ball.y - ball1.y;
			var ay1:Number = dy1 * spring;
			vy1 += ay1;
			vy1 += gravity1;
			vy1 *= fliction;
			ball1.y += vy1;
			
			//graphics.clear();
			graphics.lineStyle(1);
			graphics.moveTo(ball.x, ball.y);
			graphics.lineTo(ball1.x, ball1.y);
			
			
			
			//var dx :Number = targetX - ball.x ;
			var dx2 :Number = ball1.x - ball2.x ;
			var ax2 :Number = dx2 * spring;
			vx2 += ax2;
			vx2 *= fliction;
			ball2.x += vx2;
			
			//var dy:Number = targetY - ball.y;
			var dy2:Number = ball1.y - ball2.y;
			var ay2:Number = dy2 * spring;
			vy2 += ay2;
			vy2 += gravity2;
			vy2 *= fliction;
			ball2.y += vy2;
			
			//graphics.clear();
			graphics.lineStyle(1);
			graphics.moveTo(ball1.x, ball1.y);
			graphics.lineTo(ball2.x, ball2.y);
			
		}
		
	}
	
}