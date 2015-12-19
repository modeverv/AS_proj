package 
{
	// base rotation and reflect
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import fortest.Ball;
	import net.hires.debug.Stats;
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
		
		private var ball:Ball;
		private var line:Sprite;
		private var gravity:Number = 0.9;
		private var bounce:Number = -0.9;
		
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
			
			ball = new Ball(20,Math.random() * 0xffffff);
			addChild(ball);			
			ball.x = 100;
			ball.y = 100;
			ball.vx = 5;
			ball.vy = 5;
			line = new Sprite();
			line.graphics.lineStyle(1);
			line.graphics.lineTo(500, 0);
			addChild(line);
			line.x = 100;
			line.y = 400;
			line.rotation = 30;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
		}
		private function onMouseDown(e:MouseEvent):void {
			ball.x = Math.random() * stage.stageWidth;
			ball.y = Math.random() * stage.stageHeight;
			ball.vx = 2;
			ball.vy = 0;
			ball.x = 100;
			ball.y = 100;
		}
		private var friction :Number = 0.3;
		
		private function onEnterFrame(e:Event):void {
			//通常のモーション
			ball.vy += gravity;
						
			if (ball.x - ball.radius< 0) {
				ball.x = 0 + ball.radius;
				ball.vx *= -1 ;
				//ball.vy *= -1 ;
			}
			if (ball.x + 1 * ball.radius > stage.stageWidth) {
				ball.x = stage.stageWidth - 1 * ball.radius;
				ball.vx *= -1 ;
				//ball.vy *= -1;
			}
			if (ball.y - ball.radius < 0) {
				ball.y = 0 + ball.radius;
				//ball.vx *= -1;
				ball.vy *= -1;
			}
			if (ball.y + 1 * ball.radius > stage.stageHeight) {
				ball.y = stage.stageHeight - 1 * ball.radius;
				//ball.vx *= -1;
				ball.vy *= -1;
			}
			
			ball.x += ball.vx * friction;
			ball.y += ball.vy * friction;
			
			line.rotation = (stage.stageWidth / 2 - mouseX) * 0.1;
			
			if (ball.hitTestObject(line)) {
			//角度三角関数
			var angle:Number = line.rotation * Math.PI / 180;
			var cos:Number = Math.cos(angle);
			var sin:Number = Math.sin(angle);
			
			//ボールの位置を取得
			var x1:Number = ball.x - line.x;
			var y1:Number = ball.y - line.y;
			
			//座標系の回転
			var x2:Number = cos * x1 + sin * y1;
			var y2:Number = cos * y1 - sin * x1;
			
			//速度の回転
			var vx1:Number = cos * ball.vx + sin * ball.vy;
			var vy1:Number = cos * ball.vy - sin * ball.vx;
			
			//回転させた座標系上で衝突・跳ね返り
			if (y2 + ball.height / 2  > 10 ) {
				y2 = - ball.height / 2;
				vy1 *= bounce;
				trace(1);
			}/*
			else if (y2 - ball.height / 2 < 10) {
				y2 = 0 + ball.height / 2;
				vy1 *= bounce;				
				trace(2);
			}
		*/
			//回転させた座標軸を元に戻す
			x1 = cos * x2 - sin * y2;
			y1 = cos * y2 + sin * x2;
			ball.vx = cos * vx1 - sin * vy1;
			ball.vy = cos * vy1  + sin * vx1;
			ball.x = line.x + x1;
			ball.y = line.y + y1;
			}
			
		}
		
	}
	
}