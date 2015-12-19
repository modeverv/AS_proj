package 
{
	import adobe.utils.ProductManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.geom.Point;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;		
	
	import fortest.WeightBall;
	import fortest.Ball;
	
	import net.hires.debug.Stats;	
	
	/**
	 * ...
	 * @author modeverv
	 */
	public class Main extends Sprite 
	{
			
		public var b:Ball;
		public var b0:WeightBall;
		
		public var ball0:WeightBall;
		public var ball1:WeightBall;
		
		public var balls:Array;
		public var numBalls:uint = 90;
		public var friction:Number = 1;
		public var gravity:Number = 0;
		private var bounce:Number = - 0.9;
		
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
			
			//クラス仕様テスト
			b = new WeightBall();//ＯＫ
			b0 = new WeightBall();//ＯＫ
			addChild(b); 
			addChild(b0);
			b0.hoge("aaa"); //OK
			//b.hoge("aaa");//NG
			WeightBall(b).hoge("hoge");//キャストすればOK
/*			
			ball0 = new WeightBall(150,Math.random() * 0xffffff);
			ball1 = new WeightBall(200,Math.random() * 0xffffff);

			ball0.mass = 20;			
			ball0.x = stage.stageWidth - 200;
			ball0.y = stage.stageHeight - 200;
			ball0.vx = Math.random() * 10 ;
			ball0.vy = Math.random() * 10 ;
			addChild(ball0);
			
			ball1.mass = 10;
			ball1.x = 100;
			ball1.y = 100;
			ball1.vx = Math.random() * 10 ;
			ball1.vy = Math.random() * 10 ;
			addChild(ball1);
*/			
			balls = new Array();
			for (var i:uint = 0; i < numBalls; i++) {
				var radius:Number = Math.random() * 10 + 20;
				var color:uint = Math.random() * 0xffffff;
				var ball:WeightBall = new WeightBall(radius, color);
				ball.mass = radius;
				ball.x = i * 100;
				ball.y = i *  50;
				ball.vx = Math.random() * 10 -5;
				ball.vy = Math.random() * 10 - 5;
				addChild(ball);
				balls.push(ball);
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
//			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
		}
		private function onMouseDown(e:MouseEvent):void {
			ball0.mass = 20;			
			ball0.x = stage.stageWidth - 200;
			ball0.y = stage.stageHeight - 200;
			ball0.vx = Math.random() * 10 ;
			ball0.vy = Math.random() * 10 ;
			
			ball1.mass = 10;
			ball1.x = 100;
			ball1.y = 100;
			ball1.vx = Math.random() * 10;
			ball1.vy = Math.random() * 10 ;
			
		}
		
		private function onEnterFrame(e:Event):void {
//			ball0.x += ball0.vx;
//			ball0.y += ball0.vy;
//			ball1.x += ball1.vx;
//			ball1.y += ball1.vy;
			
/*x軸のみ			
			var dist:Number = ball1.x - ball0.x;
			if (Math.abs(dist) < ball0.radius + ball1.radius) {//衝突
				ball0.chgColor(Math.random() * 0xffffff);
				ball1.chgColor(Math.random() * 0xffffff);
				//ball0.vx *= -1;
				//ball1.vx *= -1;
				
				var vxTotal:Number = ball0.vx - ball1.vx;
				ball0.vx = ((ball0.mass - ball1.mass) * ball0.vx + 2 * ball1.mass * ball1.vx)
					/ (ball0.mass + ball1.vx);
				ball1.vx = vxTotal + ball0.vx;
				//var vx0Final:Number = ((ball0.mass - ball1.mass) * ball0.vx + 2 * ball1.mass * ball1.vx) / 
				//	(ball0.mass + ball1.mass);
				//var vx1Final:Number = ((ball1.mass - ball0.mass) * ball1.vx + 2 * ball0.mass * ball0.vx) /
				//	(ball0.mass + ball1.mass);
				
				//ball0.vx = vx0Final;
				//ball1.vx = vx1Final; 
				ball0.x += ball0.vx ;
				ball1.x += ball1.vx ;
				
				
			}
*/			
//			checkCollision(ball0, ball1);
//			checkWalls(ball0);
//			checkWalls(ball1);


			for (var i:uint = 0; i < numBalls; i++) {
				var ball:WeightBall = balls[i];
//				ball.vx *= friction;
//				ball.vy += gravity;
//				ball.vy *= friction;
				ball.x += ball.vx;
				ball.y += ball.vy;
				checkWalls(ball);
			}
			for (i = 0; i < numBalls; i++) {
				var ballA:WeightBall = balls[i];
				for (var j:Number = i + 1; j < numBalls; j++) {
					var ballB:WeightBall = balls[j];
					checkCollision(ballA, ballB);
				}
			}


		}
		

		private function checkWalls(ball:WeightBall):void {
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
		private function onBallChange(b:WeightBall):void {
			b.chgColor(Math.random() * 0xffffff);
		}
		private function checkCollisionOld(ball0:WeightBall, ball1:WeightBall):void {
			//distを
			var dx:Number = ball1.x - ball0.x;
			var dy:Number = ball1.y - ball0.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			if (dist < ball0.radius + ball1.radius) {
				trace("衝突");
				var angle:Number = Math.atan2(dy, dx);
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);
				//ball0の回転
				var x0 :Number = 0;
				var y0:Number = 0;
				var vx0:Number = ball0.vx * cos + ball0.vy * sin;
				var vy0: Number = ball0.vy * cos - ball0.vx * sin;
				//ball1の回転
				var x1 :Number = dx * cos + dy * sin ;
				var y1:Number = dy * cos - dx * sin;
				var vx1:Number = ball1.vx * cos + ball1.vy * sin;
				var vy1:Number = ball1.vy * cos - ball1.vx * sin;
				
				var vxTotal:Number = vx0 - vx1;
				vx0 = ((ball0.mass - ball1.mass) * vx0 + 2 * ball1.mass * vx1)
					/ (ball0.mass + ball1.mass);
				vx1 = vxTotal + vx0;
				
				x0 += vx0;
				x1 += vx1;
				
				var x0F:Number = x0 * cos - y0 * sin;
				var y0F:Number = y0 * cos + x0 * sin;
				var x1F:Number = x1 * cos - y1 * sin;
				var y1F:Number = y1 * cos +  x1 * sin;

				ball1.x = ball0.x + x1F;
				ball1.y = ball0.y + y1F;
				ball0.x = ball0.x + x0F;
				ball0.y = ball0.y + y0F;
				
				ball0.vx = vx0 * cos - vy0 * sin;
				ball0.vy = vy0 * cos + vx0 * sin;
				ball1.vx = vx1 * cos - vy1 * sin;
				ball1.vy = vy1 * cos + vx1 * sin;
			}
			
		}
		private function checkCollision(ball0:WeightBall, ball1:WeightBall):void {
			//distを
			var dx:Number = ball1.x - ball0.x;
			var dy:Number = ball1.y - ball0.y;
			var dist:Number = Math.sqrt(dx * dx + dy * dy);
			if (dist < ball0.radius + ball1.radius) {
				trace("衝突");
				onBallChange(ball0);
				onBallChange(ball1);
				var angle:Number = Math.atan2(dy, dx);
				var sin:Number = Math.sin(angle);
				var cos:Number = Math.cos(angle);

				//ball0の回転
				var pos0:Point = new Point(0, 0);
			
				//ball1の回転
				var pos1:Point = rotate(dx, dy, sin, cos, true);
				
				//ball0速度の回転
				var vel0:Point = rotate(ball0.vx, ball0.vy, sin, cos, true);
				
				//ball1速度の回転
				var vel1:Point = rotate(ball1.vx, ball1.vy, sin, cos, true);
				
				var vxTotal:Number = vel0.x - vel1.x;
				vel0.x = ((ball0.mass - ball1.mass) * vel0.x  + 2 * ball1.mass * vel1.x)
					/ (ball0.mass + ball1.mass);
				vel1.x = vxTotal + vel0.x;
				
				//この実装だとボール同士が埋まるエンドレス内側衝突
				//pos0.x += vel0.x;
				//pos1.x += vel1.x;
				
				var absV:Number = Math.abs(vel0.x) + Math.abs(vel1.x);
				var overlap:Number = (ball0.radius + ball1.radius) - Math.abs(pos0.x - pos1.x);
				pos0.x += vel0.x / absV * overlap;
				pos1.x += vel1.x / absV * overlap;
				
				
				var pos0F:Point = rotate(pos0.x, pos0.y, sin, cos, false);
				var pos1F:Point = rotate(pos1.x, pos1.y, sin, cos, false);

				ball1.x = ball0.x + pos1F.x;
				ball1.y = ball0.y + pos1F.y;
				ball0.x = ball0.x + pos0F.x;
				ball0.y = ball0.y + pos0F.y;
				
				//速度の回転
				var vel0F:Point = rotate(vel0.x, vel0.y, sin, cos, false);
				var vel1F:Point = rotate(vel1.x, vel1.y, sin, cos, false);
				
				ball0.vx = vel0F.x;
				ball0.vy = vel0F.y;
				ball1.vx = vel1F.x;
				ball1.vy = vel1F.y;
			}
			
		}
		
		private function rotate(x:Number,y:Number,sin:Number,cos:Number,reverse:Boolean) :Point{
			var result:Point = new Point();
			if (reverse) {
				result.x = x * cos + y * sin;
				result.y = y * cos - x * sin;
			}else {
				result.x = x * cos - y * sin;
				result.y = y * cos + x * sin;
			}
			return result;
		}
		
	}
	
}