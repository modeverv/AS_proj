package 
{
	// base rotation and reflect
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import fortest.Ball;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author modeverv
	 */
	[SWF(width="200", height="400", backgroundColor="0xFFFFFF", frameRate="30")]	 
	public class Main extends Sprite 
	{
		
		private var ball:Ball;
		private var lines:Array;
		private var nuLines:uint = 5;
		private var gravity:Number = 0.9;
		private var bounce:Number = - 0.9;
		private var friction:Number = 0.99;		
		private var xwindow:Number = - 0.01;
		
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
			ball.x = 200;
			ball.y = 100;
			ball.vx = 0;
			
			//線の作成
			lines = new Array();
			for (var i:uint = 0; i < nuLines ; i++) {
				var line:Sprite = new Sprite();
				line.graphics.lineStyle(1);
				line.graphics.moveTo( -50, 0);
				line.graphics.lineTo(50, 0);
				addChild(line);
				lines.push(line);
			}
			
			//線の配置と回転
			lines[0].x = 100;
			lines[0].y = 100;
			lines[0].rotation = 30;
			
			lines[1].x = 100;
			lines[1].y = 230;
			lines[1].rotation = 45;
			
			lines[2].x = 250;
			lines[2].y = 180;
			lines[2].rotation = - 30;
			
			lines[3].x = 150;
			lines[3].y = 330;
			lines[3].rotation =  -10;
			
			lines[4].x = 230;
			lines[4].y = 250;
			lines[4].rotation = -30;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			ball.x =  150; ball.y = 50;
			ball.vx = 1; ball.vy = 0;
		}

		private function onEnterFrame(e:Event):void {
			//normal motion code
			ball.vy += gravity;
			ball.vx += xwindow;
			if (ball.x - ball.radius< 0) {
				ball.x = ball.radius;
				ball.vx *= bounce ;
			}
			if (ball.x + 1 * ball.radius > stage.stageWidth) {
				ball.x = stage.stageWidth - 1 * ball.radius;
				ball.vx *= bounce ;
			}
			if (ball.y - ball.radius < 0) {
				ball.y = 0 + ball.radius;
				ball.vy *= bounce;
			}
			if (ball.y + 1 * ball.radius > stage.stageHeight) {
				ball.y = stage.stageHeight - 1 * ball.radius;
				ball.vy *= bounce;
			}			
			ball.vx *= friction;
			ball.vy *= friction;
			ball.x += ball.vx;
			ball.y += ball.vy;
			
			
			
			
			for (var i:uint = 0; i < nuLines ;++i) {
				checkLine(lines[i]);
			}
			
			
			
		}
		
		private function checkLine(line:Sprite):void {
			//境界ボックスを取得
			var bounds:Rectangle = line.getBounds(this);
			
			if (ball.x > bounds.left && ball.x < bounds.right) {
				//角度、サイン、コサイン
				var angle:Number = line.rotation * Math.PI / 180;
				var cos:Number = Math.cos(angle);
				var sin:Number = Math.sin(angle);
				
				//基準点からボール位置(ベクトル)
				var x1:Number = ball.x - line.x;
				var y1:Number = ball.y - line.y;
				
				//座標系に従って回転
				var y2:Number = cos * y1 - sin * x1;
				//速度回転
				var vy1:Number = cos * ball.vy - sin * ball.vx;
				
				//回転させた値を使った跳ね返り
				if (y2 + ball.radius > 0 && y2 < vy1) {
					//座標の回転
					var  x2:Number = cos * x1 + sin * y1;
					//速度の回転
					var vx1:Number = cos * ball.vx + sin * ball.vy;
					
					y2 = - ball.height / 2;
					vy1 *= bounce;
					
					//回転を戻す
					x1 = cos * x2 - sin * y2;
					y1 = cos * y2 + sin * x2;
					ball.vx = cos * vx1 - sin * vy1;
					ball.vy = cos * vy1 + sin + vx1;
					ball.x = line. x + x1;
					ball.y = line.y + y1;
					trace("omote");
				}else if (y2 - ball.radius <= 0 && y2 - vy1 >= 0) {
					//座標の回転
					var  x22:Number = cos * x1 + sin * y1;
					//速度の回転
					var vx12:Number = cos * ball.vx + sin * ball.vy;
					
					y2 =  ball.height / 2;
					vy1 *= bounce;
					
					//回転を戻す
					x1 = cos * x22 - sin * y2;
					y1 = cos * y2 + sin * x22;
					ball.vx = cos * vx12 - sin * vy1;
					ball.vy = cos * vy1 + sin + vx12;
					ball.x = line.x + x1;
					ball.y = line.y + y1;
					trace("ura");
				}
				
/*				
				//回転させた値を使った跳ね返り裏
				if (y2 > -ball.height / 2 && y2 < vy1) {
					//座標の回転
					var  x2:Number = cos * x1 + sin * y1;
					//速度の回転
					var vx1:Number = cos * ball.vx + sin * ball.vy;
					
					y2 = - ball.height / 2;
					vy1 *= bounce;
					
					//回転を戻す
					x1 = cos * x2 - sin * y2;
					y1 = cos * y2 + sin * x2;
					ball.vx = cos * vx1 - sin * vy1;
					ball.vy = cos * vy1 + sin + vx1;
					ball.x = line. x + x1;
					ball.y = line.y + y1;
				}
*/				
			}


		}
		
	}
	
}